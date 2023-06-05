public with sharing class DemoWithObjects {
  @AuraEnabled(cacheable=true)
  public static Map<String, String> fetchAllObjectList() {
    Map<String, String> mapOfAllObjects = new Map<String, String>();
    for (Schema.SObjectType objType : Schema.getGlobalDescribe().Values()) {
      String objAPIName = objType.getDescribe().getName();
      String label = objType.getDescribe().getLabel();
      mapOfAllObjects.put(objAPIName, label);
    }

    return mapOfAllObjects;
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, String> fetchAllFieldsList(String objectAPIName) {
    Map<String, Schema.SObjectType> typeMap = Schema.getGlobalDescribe();
    Map<String, String> mapOfAllFields = new Map<String, String>();
    for (
      Schema.SObjectField objFields : typeMap.get(objectAPIName)
        .getDescribe()
        .fields.getMap()
        .values()
    ) {
      mapOfAllFields.put(
        objFields.getDescribe().getName(),
        objFields.getDescribe().getName()
      );
    }
    return mapOfAllFields;
  }

  @AuraEnabled(cacheable=true)
  public static List<sObject> fetchAllRecordsOfSelectedObject(
    String strObjectName,
    String searchKey
  ) {
    Map<String, Schema.SObjectType> detail = Schema.getGlobalDescribe();
    List<String> allFieldsOfSelectedObject = new List<String>();
    for (
      Schema.SObjectField fields : detail.get(strObjectName)
        .getDescribe()
        .fields.getMap()
        .Values()
    ) {
      allFieldsOfSelectedObject.add(fields.getDescribe().getName());
    }
    string allFields = string.join(allFieldsOfSelectedObject, ',');
    //system.debug('---allFields--> ' + allFields);
    String query = 'select ' + allFields + ' from ' + strObjectName;
    if (searchKey != null && searchKey != '') {
      String key = '%' + searchKey + '%';
      /*system.debug(
        '--- allFieldsOfSelectedObject ---> ' + allFieldsOfSelectedObject
      );*/
      query += ' WHERE Name LIKE :key';
    }
    //system.debug('--- Query ---> ' + query);
    return Database.query(String.escapeSingleQuotes(query));
  }

  @AuraEnabled(cacheable=true)
  public static String sendEmailToUser(
    String objAPIName,
    String selectedFields,
    String recordIdString
  ) {
    String successMessage = 'Email Sent Successfully';
    System.debug(
      ' objAPIName' +
      objAPIName +
      ' selectedFields:: ' +
      selectedFields +
      ' recordIdString::' +
      recordIdString
    );
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objAPIName);
    Map<String, Schema.SObjectField> mfields = targetType.getDescribe()
      .fields.getMap();
    Map<String, String> selectedFieldMap = new Map<String, String>();
    List<String> stringList = recordIdString.split(',');
    Set<String> recordIdSet = new Set<String>(stringList);
    for (Schema.SObjectField objFields : mfields.values()) {
      if (selectedFields.contains(objFields.getDescribe().getName())) {
        selectedFieldMap.put(
          objFields.getDescribe().getName(),
          objFields.getDescribe().getLabel()
        );
      }
    }
    String queryStr =
      'Select ' +
      selectedFields +
      ' From ' +
      objAPIName +
      ' Where ID In:recordIdSet';
    List<SObject> recordList = Database.query(
      String.escapeSingleQuotes(queryStr)
    );
    System.debug('recordList::::::' + recordList);
    sendEmailWithTable(objAPIName, selectedFieldMap, recordList);
    return successMessage;
  }

  @AuraEnabled(cacheable=true)
  public static void sendEmailWithTable(
    String objName,
    Map<String, String> fieldMap,
    List<sObject> tableData
  ) {
    List<String> fieldsKeyList = new List<String>();
    for (String fieldAPIName : fieldMap.keySet()) {
      fieldsKeyList.add(fieldAPIName);
    }
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    List<String> toAddress = new List<String>();
    toAddress.add(UserInfo.getUserEmail());
    email.setToAddresses(toAddress);
    email.setSubject('Selected Data of : ' + objName);
    String body = '';
    body += '<html><body><table border="1" bordercolor="#FFCC00"><tr>';
    for (String fieldLabel : fieldMap.values()) {
      body += '<th>' + fieldLabel + '</th>';
    }
    body += '</tr><tr>';
    for (sObject obj : tableData) {
      body += '<tr>';
      for (Integer i = 0; i < fieldsKeyList.size(); i++) {
        body += '<td>' + obj.get(fieldsKeyList[i]) + '</td>';
      }
      body += '</tr>';
    }
    body += '</table></body></html>';
    email.setHtmlBody(body);
    System.debug(body);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    System.debug('Exit Send Email');
  }
}