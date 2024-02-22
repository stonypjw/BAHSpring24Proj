trigger MainOpportunityTrigger on Opportunity (before insert, after insert, before update, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            OppHandler.applyNamingConventionInsertOrUpdate(Trigger.new);
        }

        if(Trigger.isUpdate){
            OppHandler.applyNamingConventionInsertOrUpdate(Trigger.new);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            OppHandler.createInvoiceFromOppInsert(Trigger.new);
        }

        if(Trigger.isUpdate){
            OppHandler.createInvoiceFromOppUpdate(Trigger.new, Trigger.oldMap);
        }
    }


}