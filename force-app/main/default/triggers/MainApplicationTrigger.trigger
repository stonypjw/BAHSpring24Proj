trigger MainApplicationTrigger on Application__c  (before insert, after insert, before update, after update) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            // System.debug('MainApplicationTrigger In isAfter isInsert');

        }

        if(Trigger.isUpdate){
            // System.debug('MainApplicationTrigger In isAfter isUpdate');
            applicationTriggerHandler.createReviewRecordOnApplicationUpdate(trigger.new, trigger.oldMap);
            
        }
    }
    
}