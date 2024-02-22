trigger MainInvoiceTrigger on Invoice__c (before insert, after insert, before update, after update) {
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
            InvoiceHandler.shareWithOppOwner(Trigger.new);

            
        }

        if(Trigger.isUpdate){
            //System.debug('In isAfter isUpdate');
            InvoiceHandler.shareWithOppOwner(Trigger.new);
        }
    }
}