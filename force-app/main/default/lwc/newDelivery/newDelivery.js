import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getWarehouse from '@salesforce/apex/NewDeliveryController.getWarehouse';
import getETA from '@salesforce/apex/NewDeliveryController.getETA';
import getTrucks from '@salesforce/apex/NewDeliveryController.getTrucks';
import getDeliveryContents from '@salesforce/apex/NewDeliveryController.getDeliveryContents';
import insertNewDelivery from '@salesforce/apex/NewDeliveryController.insertNewDelivery';

export default class NewDelivery extends LightningElement {
    //disable controls
    disableToWarehouse = true;
    disableTrucks = true;
    disableTruckStatus = true;
    disabledDelAmount = true;

    //1D variable 
    fromWarehouseValue
    toWarehouseValue
    truckValue
    truckStatusValue
    eta

    //lists
    deliveryContentsList

    //Truck Status - Static
    get truckStatusOptions() {
        return [
            { label: 'Parked', value: 'Parked' },
            { label: 'En-route', value: 'En-route' },
            { label: 'Completed', value: 'Completed' },
        ];
    }

    @wire(getWarehouse) wiredWarehouse;
    @wire(getTrucks, {fromWarehouseValue: '$fromWarehouseValue'}) wiredTruck;
    
    @wire(getETA, {fromWarehouseValue: '$fromWarehouseValue', toWarehouseValue: '$toWarehouseValue'}) 
    wiredETA({data,error}){
        if(data){
            console.log(data);
            this.eta = data;
        }
        else {
            console.log("error: " + error);
            this.eta = "No available routes";
        }
    }

    @wire(getDeliveryContents, {fromWarehouseValue: '$fromWarehouseValue'}) 
    wiredDelContents({data,error}){
        if(data){
            console.log(data);
            let temp = JSON.stringify(data);
            this.deliveryContentsList = JSON.parse(temp);
        }
        else
            console.log("getDeliveryContents ERR: " + error);
    }

    get fromWarehouseOptions() {
        let value = [];
        for(let record in this.wiredWarehouse.data){
            value.push({
                label : this.wiredWarehouse.data[record].Name, 
                value : this.wiredWarehouse.data[record].Id
            });
        }
        return value;
    }

    get toWarehouseOptions() {
        let value = [];
        for(let record in this.wiredWarehouse.data){
            if(this.wiredWarehouse.data[record].Id !== this.fromWarehouseValue){
                value.push({
                    label : this.wiredWarehouse.data[record].Name, 
                    value : this.wiredWarehouse.data[record].Id
                });
            }
        }
        return value;
    }

    get truckOptions() {
        let value = [];
        for(let record in this.wiredTruck.data){
            value.push({
                label : this.wiredTruck.data[record].Name, 
                value : this.wiredTruck.data[record].Id
            });
        }
        return value;
    }

    onChangeFromWarehouse(e){
        this.fromWarehouseValue = e.detail.value;
        this.disableToWarehouse = false;
    }

    onChangeToWarehouse(e){
        this.toWarehouseValue = e.detail.value;
        this.disableTrucks = false;
    }

    onChangeTruck(e){
        this.truckValue = e.detail.value;
        this.disableTruckStatus = false;
    }

    onChangeTruckStatus(e){
        this.truckStatusValue = e.detail.value;
        this.disabledDelAmount = false;
    }

    handleInputChange(e){
        let record = this.deliveryContentsList[e.target.dataset.index];
        if(e.target.dataset.id === 'delivery'){
           record.deliveryAmount = e.target.value;
        }
    }

    onSave(){
        insertNewDelivery({
            fromWarehouse : this.fromWarehouseValue,
            toWarehouse : this.toWarehouseValue,
            truck : this.truckValue,
            status : this.truckStatusValue,
            deliveryContentsList : JSON.stringify(this.deliveryContentsList)
        })
        .then(data => {
            console.log("data: " + data);
            const evt = new ShowToastEvent({
                message: 'Record has been created successfully',
                variant: 'success'
            });
            this.dispatchEvent(evt);

            //clear fields & disable fields
            this.onCancel();
            this.disableFields();
            
        })
        .catch(error => {
            console.log("error: " + error);
            const evt = new ShowToastEvent({
                message: 'Error creating a record',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        });
    }

    onCancel(){
        console.log("onCancel");
        //clear fields
        this.template.querySelectorAll('lightning-input[data-id="delivery"]')
        .forEach(element => {
            element.value = '0';
        });
        this.disableFields();
    }

    disableFields(){
        this.disableToWarehouse = true;
        this.disableTrucks = true;
        this.disableTruckStatus = true;
        this.disabledDelAmount = true;
    }
}
