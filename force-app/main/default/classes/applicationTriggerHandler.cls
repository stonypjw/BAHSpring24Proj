public with sharing class applicationTriggerHandler {

    public static void createReviewRecordOnApplicationUpdate(List<Application__c> triggernew, Map<Id,Application__c> triggeroldMap){

        //Determine associated positions if application update is new interviewing status
        Set<Id> posIds = new Set<Id>();
        for (Application__c app : triggernew){
            if(app.Status__c == 'Interviewing' && triggerOldMap.get(app.Id).Status__c == 'Applied'){
                posIds.add(app.Position__c);
            }
            
        }
        //Determine interviewers associated with the position that has application in interviewing stage
        Map<Id,List<Interviewer__c>> intMap = new Map<Id,List<Interviewer__c>>();
        for (Position__c p : [SELECT Id, (SELECT ID FROM Interviewers__r) FROM Position__c WHERE Id IN :posIds]){
            intMap.put(p.Id,p.Interviewers__r);
        }

        //Create review records for those applications linked that has bee updated to interviewing
        List<Review__c> newRevs = new List<Review__c>(); 
        for(Application__c appCheck : triggernew){
            if(appCheck.Status__c == 'Interviewing' && triggerOldMap.get(appCheck.Id).Status__c == 'Applied'){
                for (Interviewer__c inv : intMap.get(appCheck.Position__c)){
                       Review__c rev = new Review__c();
                            rev.Interviewer__c = inv.Id;
                            rev.Application__c = appCheck.Id;
                        newRevs.add(rev);
                    
                }
            }
                      
        }

        insert newRevs;
          
    }
}