public class InterviewerHandler {
    // Constants 
    static final String APP_STATUS_INTERVIEWING = 'Interviewing';
    
    // When Interviewer is Attached to a Position Create a BLANK Review Record if Application Status = 'Interviewing'
    public static void createReviewRecord(List<Interviewer__c> intListNew){

        // Get the Position Ids from the Interview trigger.New List
        Set<Id> posIds = new Set<Id>();
        for(Interviewer__c i : intListNew){
            posIds.add(i.Position__c);
        }

        // Get the Application List
        List<Application__c> appList = [SELECT Id, Status__c, Position__c 
                                            FROM Application__c 
                                            WHERE Position__c IN :posIds 
                                            AND Status__c =: APP_STATUS_INTERVIEWING];

        // Call Utility to build the Review Records
        List<Review__c> revList = MainReviewUtility.makeRecordsAfterDupCheck(intListNew, appList);
        insert revList;
 
    } // End of createReviewRecord

    // Teacher version
    public static void createReviewFromInterviewInsert(List<Interviewer__c> triggernew){
        // Determine associated positions
        Set<Id> posIds = new Set<Id>();
        for(Interviewer__c inv: triggernew){
            posIds.add(inv.Position__c);
        }

        // Get the Application List
        List<Application__c> intApps = new List<Application__c>();
        for(Position__c p : [SELECT Id, (SELECT Id, Status__c, Position__c FROM Applications__r) FROM Position__c WHERE Id IN: posIds]){
            for(Application__c app: p.Applications__r){
                if(app.Status__c == 'Interviewing'){
                    intApps.add(app);
                }
            }
        }

        // Create review Records for those applications linked to the new interviewer
        List<Review__c> newRevs = new List<Review__c>();
        for(Interviewer__c invCheck : triggernew){
            for(Application__c app : intApps){
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