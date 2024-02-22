public with sharing class interviewerTriggerHandler { 

    /*Method user story ABC-123*/
    public static void createReviewRecordOnInterviewerInsert(List<Interviewer__c> triggernew){

        //Determine associated positions
        Set<Id> posIds = new Set<Id>();
        for (Interviewer__c inv : triggernew){
            posIds.add(inv.Position__c);
        }
        //Determine applications associated with the position that are in interviewing stage
        List<Application__c> intApps = new List<Application__c>();
        for (Position__c p : [SELECT Id, (SELECT ID,Position__c,Status__c FROM Applications__r) FROM Position__c WHERE Id IN :posIds]){
            for(Application__c app: p.Applications__r){
                if(app.Status__c == 'Interviewing'){
                    intApps.add(app);
                }
            }
        }

        //Create review records for those applications linked to the new interviewer
        List<Review__c> newRevs = new List<Review__c>(); 
        for(Interviewer__c invCheck : triggernew){
            //Get what position this interviewer is linked to and then create review records for each eligible application
            for (Application__c app : intApps){
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