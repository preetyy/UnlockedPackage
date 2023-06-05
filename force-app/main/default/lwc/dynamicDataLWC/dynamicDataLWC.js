/* eslint-disable guard-for-in */
import { LightningElement, track } from "lwc";
import fetchAllObjects from "@salesforce/apex/DemoWithObjects.fetchAllObjectList";
import fetchAllFieldsList from "@salesforce/apex/DemoWithObjects.fetchAllFieldsList";
import fetchAllRecordsOfSelectedObject from "@salesforce/apex/DemoWithObjects.fetchAllRecordsOfSelectedObject";
import sendEmaiToUser from "@salesforce/apex/DemoWithObjects.sendEmailToUser";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class FetchObjects extends LightningElement {
  @track objectList = [];
  @track allObjectList = [];
  @track customObjectList = [];
  @track standardObjectList = [];
  @track fieldsList = [];
  lstSelectedRecords = [];
  searchKey = "";
  objectName = "";
  selectedFields = "";
  selectedIds = "";
  showButton = false;
  showSendEmailButton = false;
  showFields = false;
  arrayToSend = [];
  allRecordsOfSelectedObject = [];
  columnsMap = [];

  @track objectTypeList = [
    { label: "All", value: "All" },
    { label: "Custom", value: "Custom" },
    { label: "Standard", value: "Standard" }
  ];

  connectedCallback() {
    fetchAllObjects()
      .then((result) => {
        if (result) {
          // eslint-disable-next-line guard-for-in
          for (let key in result) {
            if (key.endsWith("__c")) {
              this.customObjectList.push({ label: key, value: key });
            } else if (!key.endsWith("__c")) {
              this.standardObjectList.push({ label: key, value: key });
            }
            this.allObjectList.push({ label: key, value: key });
          }
        } else {
          console.log("Objects are not found");
        }
      })
      .catch((error) => {
        console.log("Object not found error" + error);
      });
  }

  onObjectTypeChange(event) {
    this.showFields = true;
    this.fieldsList = [];
    this.allRecordsOfSelectedObject = [];
    this.columnsMap = [];
    this.lab = [];
    this.val = [];
    this.arrayToSend = [];
    this.showButton = false;
    if (event.detail.value === "All") {
      this.objectList = this.allObjectList;
    } else if (event.detail.value === "Custom") {
      this.objectList = this.customObjectList;
    } else if (event.detail.value === "Standard") {
      this.objectList = this.standardObjectList;
    }
  }

  onObjectChange(event) {
    this.objectName = event.detail.value;
    this.fieldsList = [];
    this.allRecordsOfSelectedObject = [];
    this.columnsMap = [];
    this.lab = [];
    this.val = [];
    this.arrayToSend = [];
    this.showButton = false;
    fetchAllFieldsList({ objectAPIName: this.objectName })
      .then((result) => {
        for (let key in result) {
          this.fieldsList.push({ label: key, value: key });
        }
      })
      .catch((error) => {
        console.log("Error in getting fields" + error);
      });
  }

  handleFieldChange(event) {
    this.selectedFields = event.detail.value;
    this.showButton = true;
    this.arrayToSend = [];
    for (let index in event.detail.value) {
      this.arrayToSend.push(event.detail.value[index]);
    }
    let val = this.arrayToSend; // same ['Id','Name']
    this.columnsMap = val.map((v, i) => ({ label: val[i], fieldName: v }));
  }

  handleShowData() {
    //this.showFields = false;
    this.showSendEmailButton = true;
    fetchAllRecordsOfSelectedObject({
      strObjectName: this.objectName,
      searchKey: this.searchKey
    })
      .then((result) => {
        this.allRecordsOfSelectedObject = result;
      })
      .catch((error) => {
        console.log("error while getting records ", error);
      });
  }
  handleKeyChange(event) {
    this.searchKey = event.target.value;
    this.handleShowData();
  }

  getSelectedRec() {
    var selectedRecords = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows();
    if (selectedRecords.length > 0) {
      let ids = "";
      selectedRecords.forEach((currentItem) => {
        ids = ids + "," + currentItem.Id;
      });
      this.selectedIds = ids.replace(/^,/, "");
      this.lstSelectedRecords = selectedRecords;
    }
    console.log("Seleled Object: " + this.objectName);
    console.log("Seleled fields: " + this.selectedFields);
    console.log("Seleled Ids: " + this.selectedIds);
    this.selectedFields = this.selectedFields.toString();
    sendEmaiToUser({
      objAPIName: this.objectName,
      selectedFields: this.selectedFields,
      recordIdString: this.selectedIds
    })
      .then((result) => {
        this.handleSuccess(result);
      })
      .catch((error) => {
        console.log("Error in Sending Email" + error.getMessage());
      });
  }

  handleSuccess(result) {
    // Handle success logic here
    const toastEvent = new ShowToastEvent({
      title: "Success",
      message: "Email Sent Successfully",
      variant: "success"
    });
    console.log(result);
    this.dispatchEvent(toastEvent);
  }
}