import {contract} from 'truffle-contract';
import {Component, OnInit} from '@angular/core';
import {ContractService} from './../../services/contract/contract.service';
import {FormGroup, FormBuilder, Validators} from '@angular/forms';
import {MdcSnackbar} from "@angular-mdc/web";
// import { MdcSnackbar } from '@angular-mdc/web';

type TransactionField = 'sendaddress' | 'amount';

// type FormErrors = {[u in TransactionField]: string};
@Component({
  selector: 'app-registerPatient',
  templateUrl: './registerPatient.component.html',
  styleUrls: ['./registerPatient.component.scss']
})
export class RegisterPatientComponent  {

  address:any;
  name:any;
  compatible: boolean;
  direction: string;
  balance: string;
  dob:any;
  gender:any;

  constructor( private contract: ContractService, private snackbar: MdcSnackbar) {
    this.compatible = contract.compatible;
    contract.seeAccountInfo().then((value: any) => {
      this.direction = value.originAccount;
      console.log(this.direction);
      this.balance = value.balance;
    }).catch((error: any) => {
      contract.failure('Could\'t get the account data, please check if metamask is running correctly and refresh the page');
    });



    //test
//
//     this.contract.getAllDoctor(this.direction).then((r) => {
//       console.log("rr",r)
//       // this.contract.succes();
// // tslint:disable-next-line: no-shadowed-variable
//     }).catch((e) => {
//       this.contract.failure('Transaction failed');
//     });
  }

  submit(){

    console.log("register patient");
    this.contract.registerPatient(this.direction, this.name, this.dob,this.gender).then((r) => {
      this.contract.succes();
// tslint:disable-next-line: no-shadowed-variable
    }).catch((e) => {
      this.contract.failure('Transaction failed');
    });
  }


}
