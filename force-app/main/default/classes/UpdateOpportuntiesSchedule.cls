global class UpdateOpportuntiesSchedule implements Schedulable{
    
    // implements exectue method to schedule batch class

    global void execute(SchedulableContext sc){
        Id jobId = Database.executeBatch(new UpdateOpportunitiesBatch());

        System.debug('jobId: ' + jobId);

        
    }



}