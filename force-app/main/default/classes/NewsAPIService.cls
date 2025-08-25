/**
 * Service class to interact with the NewsAPI for fetching top headlines
 */
public with sharing class NewsAPIService {
    // TODO: Define API endpoint constants
    private static final String API_NAMED_CREDENTIAL = 'callout:NewsAPI'; //https://newsapi.org
    private static final String API_ENDPOINT = '/v2/top-headlines';
    private static final String API_CATEGORY = '?category=';
    private static final String API_PAGE_SIZE = '&pageSize=';
    private static final String API_PAGE = '&page=';
    private static final String API_KEY = '&apiKey=';
    private static final String API_KEY_NAME = 'NewsAPI';
    private static final String API_GET_METHOD = 'GET';
    private static final Integer INITIAL_SUCCESS_CODE = 200;
    private static final Integer ENDING_SUCCESS_CODE = 299;
    
    // TODO: Define default parameters
    public static final Integer PAGE_SIZE = 30;
    private static List<String> categoryNames = new List<String>{'business', 'entertainment', 'general','health', 'science', 'sports', 'technology'};
    /**
     * Fetches top headlines for a specified category with pagination support
     * @param category The news category (business, entertainment, general, health, science, sports, technology)
     * @param page Page number for pagination
     * @return NewsAPIResponse The wrapper object containing the API response
     */
    public static NewsAPIResponse getTopHeadlinesByCategory(String category, Integer page) {
        APIKeys__mdt apiKey = APIKeys__mdt.getInstance(API_KEY_NAME);
        String endPointForCall;
        // TODO: Implement method to fetch headlines by category
        // - Validate parameters
        if (categoryNames.contains(category.toLowerCase())) {
            // - Build the request URL with fixed page size
            endPointForCall = API_NAMED_CREDENTIAL + API_ENDPOINT + API_CATEGORY + category + 
                                API_PAGE_SIZE + PAGE_SIZE + API_PAGE + page + API_KEY + apiKey.Key__c;
        }
        // - Make the callout
        HttpResponse response = makeCallout(endPointForCall);
        // - Parse and return the response
        String stringResp = response.getBody();
        NewsAPIResponse parsedResponse = parseResponse(stringResp);
        return parsedResponse;
    }
    
    /**
     * Helper method to make the HTTP callout
     * @param endpoint The full URL with parameters
     * @return HttpResponse The HTTP response
     */
    private static HttpResponse makeCallout(String endpoint) {
        // TODO: Implement HTTP callout
        // - Create and configure HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(API_GET_METHOD);
        // - Make the callout
        Http http = new Http();
        HttpResponse res = http.send(req);
        String restResp;
        // - Handle exceptions
        if (res.getStatusCode() >= INITIAL_SUCCESS_CODE && res.getStatusCode() <= ENDING_SUCCESS_CODE) {
            restResp = res.getBody();
        } else {
            throw new CalloutException('Error while sending request');
        }
        return res;
    }
    
    /**
     * Helper method to parse the JSON response
     * @param jsonResponse The JSON response string
     * @return NewsAPIResponse The parsed response object
     */
    private static NewsAPIResponse parseResponse(String jsonResponse) {
        // TODO: Implement JSON parsing
        NewsAPIResponse napiResponse;
        // - Deserialize JSON to NewsAPIResponse
        try {
            napiResponse = (NewsAPIResponse)JSON.deserialize(jsonResponse, NewsAPIResponse.class);
        // - Handle exceptions
        } catch (NewsAPIException ex) {
            System.debug(ex.getMessage());
        }
        return napiResponse;
    }
    
    /**
     * Custom exception class for NewsAPI errors
     */
    public class NewsAPIException extends Exception {}
} 