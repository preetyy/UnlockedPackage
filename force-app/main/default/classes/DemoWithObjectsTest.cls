@IsTest
public class DemoWithObjectsTest {
    @IsTest
    static void testFetchAllRecordsOfSelectedObject() {
        // Test data setup
        String objectName = 'Account';
        String searchKey = 'Test';
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Call the method being tested
        Test.startTest();
        List<sObject> result = DemoWithObjects.fetchAllRecordsOfSelectedObject(objectName, searchKey);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(1, result.size());
        Account fetchedAccount = (Account)result[0];
        System.assertEquals(testAccount.Id, fetchedAccount.Id);
        System.assertEquals(testAccount.Name, fetchedAccount.Name);
    }
    
    // Mock class for Schema.SObjectType
    private class MockDescribeSObjectType implements System.StubProvider {
        private Map<String, Schema.SObjectType> globalDescribe;
        
        public MockDescribeSObjectType(Map<String, Schema.SObjectType> globalDescribe) {
            this.globalDescribe = globalDescribe;
        }
        
        public Object handleMethodCall(Object stub, String methodName, Type retType, List<Type> argTypes, List<String> argNames, List<Object> args) {
            if (methodName == 'getDescribe') {
                return globalDescribe.get((String)args[0]);
            }
            return null;
        }
    }
    @isTest
    static void testFetchAllObjectList_New() {
        // Call the method being tested
        Map<String, String> result = DemoWithObjects.fetchAllObjectList();
        
        // Perform assertions
        System.assertNotEquals(0, result.size(), 'The result should not be an empty map');
        
        // Add additional assertions if needed
    }
    
    @isTest
    static void testFetchAllFieldsList() {
        // Test parameters
        String objectAPIName = 'Account';

        // Call the method to test
        Test.startTest();
        Map<String, String> result = DemoWithObjects.fetchAllFieldsList(objectAPIName);
        Test.stopTest();

        // Verify the result
        System.assertNotEquals(null, result);
        System.assertNotEquals(0, result.size());

        // Perform additional verifications if necessary
    }
    
    
     @isTest
    static void testSendEmailToUser() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Test parameters
        String objAPIName = 'Account';
        String selectedFields = 'Name';
        String recordIdString = String.valueOf(testAccount.Id);

        // Call the method to test
        Test.startTest();
        String result = DemoWithObjects.sendEmailToUser(objAPIName, selectedFields, recordIdString);
        Test.stopTest();

        // Verify the result
        System.assertEquals('Email Sent Successfully', result);

        // Perform additional verifications if necessary
    }
    @isTest
    static void testSendEmailWithTable() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Test parameters
        String objName = 'Account';
        Map<String, String> fieldMap = new Map<String, String>{'Name' => 'Account Name'};
        List<sObject> tableData = new List<sObject>{testAccount};

        // Call the method to test
        Test.startTest();
        DemoWithObjects.sendEmailWithTable(objName, fieldMap, tableData);
        Test.stopTest();

        // Perform verifications/assertions if necessary
    }
}