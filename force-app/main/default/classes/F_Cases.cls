public class F_Cases {

    public static string CLOSED_STATUS = 'Closed';

    /**
     * Avoid duplicated processing caused by
     * - rollup summary fields
     * - workflow rules
     * - any other process that makes trigger run twice
     */
    public static Set<Id> processedIds = new Set<Id>();

    // Logic to auto populate the member field
    public static void onBeforeInsert(List<Case> records) {
        Set<Id> userIds = new Set<Id>();
        for (Case record : records) {
            if (record.Status == 'Closed') {
                record.F_SLAInHours__c = 0;
            }
            userIds.add(record.CreatedById);
        }

        Map<Id,Id> memberIdByUserIdMap = new Map<Id,Id>();

        for (FieloPLT__Member__c member : [ SELECT Id, FieloPLT__User__c
                                            FROM FieloPLT__Member__c
                                            WHERE FieloPLT__User__c IN :userIds]) {
            if (memberIdByUserIdMap.containsKey(member.FieloPLT__User__c)) continue;

            memberIdByUserIdMap.put(member.FieloPLT__User__c, member.Id);
        }

        for (Case record : records) {
            if (!memberIdByUserIdMap.containsKey(record.CreatedById)) continue;

            record.Member__c = memberIdByUserIdMap.get(record.CreatedById);
        }
    }

    public static void onAfterInsert(List<Case> records) {
        FieloPLT.SObjectService.processRecords(records, null);
    }

    public static void onBeforeUpdate(List<Case> records, Map<Id,Case> existingRecords) {
        for (Case record : records) {
            Case oldRecord = existingRecords.get(record.Id);

            if (record.Status == CLOSED_STATUS && oldRecord.Status != CLOSED_STATUS) {
                Long hours = (record.ClosedDate.getTime() - record.CreatedDate.getTime()) / 1000 / 60 / 60;
                record.F_SLAInHours__c = hours.intValue();
                record.F_SLAInDays__c = Math.floor(hours.intValue()/24).intValue();
            }
        }
    }

    public static void onAfterUpdate(List<Case> records, Map<Id,Case> existingRecords) {
        List<Case> recordsToProcess = new List<Case>();
        Map<Id,Case> mapExistingRecordsToProcess = new Map<Id,Case>();
        for(Case record : (List<Case>)records){
            if(!processedIds.contains(record.Id)){
                recordsToProcess.add(record);
                mapExistingRecordsToProcess.put(record.Id,(Case)existingRecords.get(record.Id));
                processedIds.add(record.Id);
            }
        }
        if(!recordsToProcess.isEmpty()){
            FieloPLT.SObjectService.processRecords(recordsToProcess, mapExistingRecordsToProcess);
        }
    }
}
