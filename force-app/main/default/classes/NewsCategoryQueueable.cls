/**
 * Queueable Apex class for processing News Category records with pagination support
 */
public class NewsCategoryQueueable implements Queueable, Database.AllowsCallouts {
    // Static variable for maximum pages to fetch
    private static Integer MAX_PAGES;
    private News_Category__c category;
    private Integer currentPage;
    
    /**
     * Constructor
     * @param category The News_Category__c record
     * @param currentPage Current page to process
     */
    public NewsCategoryQueueable(News_Category__c category, Integer currentPage) {
        // TODO: Initialize with category and current page
        this.category = category;
        this.currentPage = currentPage;
    }
    
    /**
     * Execute method for the queueable job
     * @param context The QueueableContext
     */
    public void execute(QueueableContext context) {
        // IMPORTANT: Create a separate instance of the category for updates
        if (category.Sync__c == true) {
            News_Category__c updatedCategory = new News_Category__c(Id = category.Id);
            List<Article__c> articlesForInsert = new List<Article__c>();
            try {
                // TODO: Implement execute method
                // - Call NewsAPI for the current page
                NewsAPIResponse wrapperObj = new NewsAPIResponse();
                wrapperObj = NewsAPIService.getTopHeadlinesByCategory(category.Name, currentPage);
                // - Convert API articles to Salesforce articles using NewsAPIResponse.convertToSObject
                for (NewsAPIResponse.Article art : wrapperObj.articles) {
                    Article__c artRec = NewsAPIResponse.convertToSObject(art);
                    // - Add category reference to each article
                    artRec.News_Category__c = category.Id;
                    artRec.Category__c = category.Name;
                    articlesForInsert.add(artRec);
                }
                // - Insert the articles
                insert articlesForInsert;
                this.currentPage ++;
                MAX_PAGES = (Integer)Math.ceil(((Decimal)wrapperObj.totalResults / NewsAPIService.PAGE_SIZE));
                // - Check if reached MAX_PAGES or no more articles
                if (currentPage <= MAX_PAGES && wrapperObj.articles != null && !wrapperObj.articles.isEmpty() && !Test.isRunningTest()) {
                    System.enqueueJob(new NewsCategoryQueueable(category, currentPage));
                } else {
                    updatedCategory.Sync__c = false;
                    updatedCategory.Last_Synced__c = Datetime.now();
                    update updatedCategory;
                }
                // HINT: When requeuing the job check if tests are running
                // - Update category with last synced date and sync flag = false
            } catch (Exception e) {
                // TODO: Handle errors
                // - Update category with error information
                // - Log error to debug logs
            }
        }
            
    }
} 