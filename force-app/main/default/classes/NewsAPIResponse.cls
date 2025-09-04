/**
 * Wrapper class for parsing the NewsAPI response
 */
public class NewsAPIResponse {
    private static final String NO_NAME = 'Without Title';
    private static final String NO_AUTHOR = 'Without Author';
    private static final String NO_CONTENT = 'Without Content';
    private static final String NO_DESCRIPTION = 'Without Description';
    private static final String NO_SOURCE = 'Without Source';
    // TODO: Define fields to match the NewsAPI response structure
    public String status { get; set; }
    public Integer totalResults { get; set; }
    public List<Article> articles { get; set; }
    
    /**
     * Inner class representing a news article
     */
    public class Article {
        // TODO: Define article fields
        // Example fields:
        public Source source { get; set; }
        public String author { get; set; }
        public String title { get; set; } 
        public String description { get; set; }
        public String url { get; set; }
        public String urlToImage { get; set; }
        public Datetime publishedAt { get; set; }
        public String content { get; set; }
    }
    
    /**
     * Inner class representing a news source
     */
    public class Source {
        // TODO: Define source fields
        public String id { get; set; }
        public String name { get; set; }
    }
    
    /**
     * Static method to convert an API article to a Salesforce Article__c record
     * @param apiArticle The API article to convert
     * @return Article__c The Salesforce record
     */
    public static Article__c convertToSObject(Article apiArticle) {
        // TODO: Implement conversion from API article to Salesforce record
        // Consider:
        Article__c article = new Article__c();
        // - Generating a unique record name
        article.Name = apiArticle?.title != null ? apiArticle.title.left(75) : NO_NAME;
        // - Setting article fields from the API response
        // - Handling content length limits if needed
        // - Handling date conversion 
        //Gets first 250 charachters of the Author parameter of Article, if the value is null, then sets Default value: 'Without Author'
        article.Author__c = apiArticle?.author != null ? apiArticle.author.left(250) : NO_AUTHOR;
        //Gets value of the Content parameter of Article, if the value is null, then sets Default value: 'Without Content'
        article.Content__c = apiArticle?.content != null ? apiArticle.content : NO_CONTENT;
        //Gets value of the Content parameter of Article, if the value is null, then sets Default value: 'Without Description'
        article.Description__c = apiArticle?.description != null ? apiArticle.description : NO_DESCRIPTION;
        article.Published_At__c = apiArticle?.publishedAt;
        //Gets value of the Content parameter of Source Id and Source Name, and concatenetes them to get new value
        article.Source__c = (apiArticle?.source?.id + '_' + apiArticle?.source?.name).left(250);
        return article;
    }
} 