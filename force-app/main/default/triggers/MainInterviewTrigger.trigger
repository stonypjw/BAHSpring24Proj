trigger MainInterviewTrigger on Interviewer__c (before insert, after insert, before update, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            //System.debug('In isBefore isInsert');

        }

        if(Trigger.isUpdate){
            //System.debug('In isBefore isUpdate');
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            //System.debug('In isAfter isInsert');
            interviewerTriggerHandler.createReviewRecordOnInterviewerInsert(trigger.new);

            
        }

        if(Trigger.isUpdate){
            //System.debug('In isAfter isUpdate');

        }
    }


}