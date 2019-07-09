import { Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { LaneService } from '../../../services/Lane.service';
import { FormGroup,  FormBuilder,  Validators } from '@angular/forms';
import { BaseComponent } from '../../base.component';
import { SubBaseComponent } from '../../Lane/sub.base.component';

@Component({
  selector: 'app-create',
  templateUrl: './create.component.html',
  styleUrls: ['./create.component.css']
})
export class CreateLaneComponent extends SubBaseComponent implements OnInit {

  title = 'Add Lane';
  laneForm: FormGroup;
  
  constructor(  http: HttpClient,
  				private laneservice: LaneService, 
  				private fb: FormBuilder, 
  				private router: Router) {
	super(http);
    this.createForm();
   }
  createForm() {
    this.laneForm = this.fb.group({
      number: ['', Validators.required]
   });
  }
  addLane(number) {
      this.laneservice.addLane(number)
      	.then(success => this.router.navigate(['/indexLane']) );
  }
  
// initialization  
  ngOnInit() {
  	super.ngOnInit();
  }
}
