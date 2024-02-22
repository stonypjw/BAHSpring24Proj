public class ApplicationHandler {
    // Constants 
    static final String APP_STATUS_INTERVIEWING = 'Interviewing';

    // If Application Record moves to Status 'Interviewing' need to make sure Review Records are created
    public static void createReviewRecord(List<Application__c> appListNew){

        // Filter out the Applications that are NOT status = 'Interviewing';
        List<Application__c> filteredAppList = new List<Application__c>();
        for( Application__c a : appListNew ){
            if(a.Status__c.equals(APP_STATUS_INTERVIEWING)){
                filteredAppList.add(a);
            }
        }

         // Get Position List to get Interview List (Interview is required for Review Record)
         Set<Id> posIds = new Set<Id>();
         for(Application__c a : filteredAppList){
             posIds.add(a.Position__c);
         }

        // Get Interview Records for Review Record Insert
        List<Interviewer__c> intList = [SELECT Id, Position__c 
                                        FROM Interviewer__c 
                                        WHERE Position__c IN :posIds 
                                        ];
           
        List<Review__c> revList = makeReviewRecords(intList, filteredAppList);
        if(revList.size() > 0){
            insert revList;
        }
    }

    public static List<Review__c> makeReviewRecords(List<Interviewer__c> intList, List<Application__c> appList){
        // Blank list to hold records
        List<Review__c> revList = new List<Review__c>();
        for(Interviewer__c i : intList){
            for(Application__c a : appList){
                if(i.Position__c == a.Position__c && a.Status__c.equals(APP_STATUS_INTERVIEWING)){
                    //Create review record
                    Review__c rev = new Review__c();
                    rev.Application__c = a.Id;
                    rev.Interviewer__c = i.Id;
                    rev.Name = 'Review from Automation';
                    revList.add(rev);
                } else if(!a.Status__c.equals(APP_STATUS_INTERVIEWING)){
                    // TODO Custom error if have time
                    System.debug('Application Status is not ' + APP_STATUS_INTERVIEWING);
                }
                
            }
        }
        return revList;

    }

    // Teacher method
    public static void makeReviewFromApplicationUpdate(List<Application__c> triggernew, Map<Id, Application__c> triggerOldMap){

        // Filter out the Applications that are NOT status = 'Interviewing';
        List<Application__c> filteredAppList = new List<Application__c>();
        for( Application__c a : triggernew ){
            if(a.Status__c.equals(APP_STATUS_INTERVIEWING) && triggerOldMap.get(a.Id).Status__c != APP_STATUS_INTERVIEWING){
                filteredAppList.add(a);
            }
        }

         // Get Position List to get Interview List (Interview is required for Review Record)
         Set<Id> posIds = new Set<Id>();
         for(Application__c a : filteredAppList){
             posIds.add(a.Position__c);
         }

        // Get Interview Records for Review Record Insert
        List<Interviewer__c> intList = [SELECT Id, Position__c 
                                        FROM Interviewer__c 
                                        WHERE Position__c IN :posIds 
                                        ];

        // interate and create
        List<Review__c> newRevs = new List<Review__c>();

        for(Application__c app : filteredAppList){
            for(Interviewer__c invCheck : intList){
                if(app.Position__c == invCheck.Position__c){
                    Review__c rev = new Review__c();
                    rev.Interviewer__c = invCheck.Id;
                    rev.Application__c = app.Id;
                    newRevs.add(rev);
                }
            }
        }
        insert newRevs;

    }

}