public with sharing class mc_ToolingResponse {
    @AuraEnabled
    public Integer size;
    @AuraEnabled
    public Integer totalSize;
    @AuraEnabled
    public Boolean done;
    @AuraEnabled
    public List<mc_MergeExternalServices_Definition> records;
}