public with sharing class MainReviewUtility {
    // Constants 
    static final String APP_STATUS_INTERVIEWING = 'Interviewing';

    public static List<Review__c> makeReviews(List<Interviewer__c> intList, List<Application__c> appList){
        // Blank list to hold records
        List<Review__c> revList = new List<Review__c>();

        // Duplicate Checker
        // Get Application Ids for Review Record Dup Checker
        Set<Id> appIds = new Set<Id>();
        for(Application__c a : appList){
            appIds.add(a.Id);
        }

        Set<Id> intIds = new Set<Id>();
        for(Interviewer__c i : intList){
            intIds.add(i.Id);
        }

        List<Review__c> revDupCheck = new List<Review__c>();        

        //if revDupCheck is empty make all the records
        if(revDupCheck.size() == 0){
            if(intList.size() > 0 && appList.size() > 0){
                // call method to iterate lists
                System.debug('No previous records found!');
                return makeRecordsAfterDupCheck(intList, appList);
            } else if(intList.size() <= 0) {
                // TODO Custom error if have time
                System.debug('No Interviewer Found!');
            } else if(appList.size() <= 0){
                // TODO Custom error if have time
                System.debug('No Application Found!');
            }
        } else {
            // filter out the Applications that already have a review
            List<Application__c> appAfterDupList = new List<Application__c>();

            for(Application__c a : appList){
                for(Review__c r : revDupCheck){
                    if(a.Id != r.Application__c  ){
                        appAfterDupList.add(a);
                    }
                }
            }

            // Filter out any Interviews that already have a Review
            List<Interviewer__c> intAfterDupList = new List<Interviewer__c>();
            for(Interviewer__c i : intList){
                for(Review__c r : revDupCheck){
                    if(i.Id != r.Interviewer__c){
                        intAfterDupList.add(i);
                    }
                }
            }   
            return makeRecordsAfterDupCheck(intAfterDupList, appAfterDupList); 
        }  
        return revList;
    }

    public static List<Review__c> makeRecordsAfterDupCheck(List<Interviewer__c> intList, List<Application__c> appList){
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
                }
                
            }
        }
        return revList;

    }
}