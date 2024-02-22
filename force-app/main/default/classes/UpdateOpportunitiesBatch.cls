global class UpdateOpportunitiesBatch implements Database.Batchable<SObject> {
    
    // get all Opps
    global Database.QueryLocator start(Database.BatchableContext bc){
        // This should really be filtered more
        return Database.getQueryLocator('SELECT Id FROM Opportunity');
    }

    // cause the before update to then call the applyNamingCnvention method
    global void execute(Database.BatchableContext bc, List<Opportunity> opps){
        Database.update(opps, false);
    }

    // Do stuff on completion as needed
    global void finish(Database.BatchableContext bc){
        System.debug('Batch Process: ' + bc.getJobId() + ' completed.');
    }



}