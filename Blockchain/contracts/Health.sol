pragma solidity 0.5.0;

contract Health {

  struct docter {
    bool exist;
    string name;

  }

  struct record{

    string prescriptionData;
    address docterAddress;
    string visitDate;
    string additionalNotes;
    string fromPlace; // location clinic
  }

  struct access{
    bool createOnly;
    bool viewOnly;
  }


  struct patient {
    bool exist;
    string name;
    string DOB;
    string gender;
    mapping(address => access) docters;

    record[] records;
  }

  address government;

  mapping(address => docter) public docters;
  mapping(address => patient)  patients;

  address[] public doctersArray;
  address[] public patientsArray;

  modifier onlyGovernment() {
    require(msg.sender == government);
    _;
  }

  constructor()public{
    government = msg.sender;
  }

  function addDocter(address _addr,string memory _name) public onlyGovernment returns (bool) {   // Government can only add docter
    require(!docters[_addr].exist,'Docter Already exist');

    docters[_addr].name = _name;
    docters[_addr].exist = true;

    doctersArray.push(_addr);
    return true;

  }

  function removeDocter(address _addr) public onlyGovernment returns (bool) {// Government can only remove docter
    require(docters[_addr].exist,'Docter does not exist');

    docters[_addr].exist = false;

    return true;

  }

  function registerPatient(string memory _name,string memory _DOB,string memory _gender) public  returns (bool) {    // any one can register as a patient
    require(!patients[msg.sender].exist,'Patient Already exist');

    patients[msg.sender].exist = true;
    patients[msg.sender].name = _name;
    patients[msg.sender].DOB = _DOB;
    patients[msg.sender].gender = _gender;

    patientsArray.push(msg.sender);


    return true;

  }


  function giveCreateOnlyAccessToDocter(address _addr) public  returns (bool) {  //patient give access to docter
    require(docters[_addr].exist,'Docter does not exist');
    require(patients[msg.sender].exist,'Patient record does not exist.Please register first!!');
    require(!patients[msg.sender].docters[_addr].createOnly,'Docter already has access !!');

    patients[msg.sender].docters[_addr].createOnly = true;

    return true;
  }

  function revokeCreateOnlyAccessToDocter(address _addr) public  returns (bool) {  //patient revoke access to docter
    require(docters[_addr].exist,'Docter does not exist');
    require(patients[msg.sender].exist,'Patient record does not exist.Please register first!!');
    require(patients[msg.sender].docters[_addr].createOnly,'Docter do not has access !!');

    patients[msg.sender].docters[_addr].createOnly = false;

    return true;
  }

  function giveViewOnlyAccessToDocter(address _addr) public  returns (bool) {  //patient give  view access to docter
    require(docters[_addr].exist,'Docter does not exist');
    require(patients[msg.sender].exist,'Patient record does not exist.Please register first!!');
    require(!patients[msg.sender].docters[_addr].viewOnly,'Docter already has access !!');

    patients[msg.sender].docters[_addr].viewOnly = true;

    return true;
  }

  function revokeViewOnlyAccessToDocter(address _addr) public  returns (bool) {  //patient  view revoke access to docter
    require(docters[_addr].exist,'Docter does not exist');
    require(patients[msg.sender].exist,'Patient record does not exist.Please register first!!');
    require(patients[msg.sender].docters[_addr].viewOnly,'Docter do not has access !!');

    patients[msg.sender].docters[_addr].viewOnly = false;

    return true;
  }

  function addPrescriptionForPatient(address _addr, string memory _prescription,string memory _visitDate,string memory _additionalNotes, string memory _fromPlace) public  returns (bool) {  //docter adds prescription for patient
    require(docters[msg.sender].exist,'Docter does not exist. please register first');
    require(patients[_addr].exist,'Patient record does not exist.');
    require(patients[_addr].docters[msg.sender].createOnly,'Docter do not has access !!');


    record memory newRecord = record({

      prescriptionData:_prescription,
      docterAddress:msg.sender,
      visitDate:_visitDate,
      additionalNotes:_additionalNotes,
      fromPlace:_fromPlace
      });

    patients[_addr].records.push(newRecord);

    return true;
  }


  function getDoctersCount() public view returns(uint count) {
    return doctersArray.length;
  }


  function getPatientsCount() public view returns(uint count) {
    return patientsArray.length;
  }



  function getPatientsWithCreateOnlyAccess() public view  returns(address[] memory _patients) { // docter can get all patients with create record access
    require(docters[msg.sender].exist,'Docter Not Registered');

    uint  count = patientsArray.length;

    address[] memory dataList = new address[](count);

    for( uint i = 0 ; i < getPatientsCount() ; i++){

      if(patients[patientsArray[i]].docters[msg.sender].createOnly){

        dataList[i] = patientsArray[i];

      }
    }
    return dataList;

  }

  function getPatientsWithViewOnlyAccess() public view  returns(address[] memory _patients) { // docter can get all patients with viewOnly access
    require(docters[msg.sender].exist,'Docter Not Registered');


    uint  count = patientsArray.length;

    address[] memory dataList = new address[](count);

    for( uint i = 0 ; i < getPatientsCount() ; i++){

      if(patients[patientsArray[i]].docters[msg.sender].viewOnly){

        dataList[i] = patientsArray[i];

      }
    }
    return dataList;

  }


  function getDoctersWithViewOnlyAccess() public view  returns(address[] memory _docters) { // patients can get all docter that have their view access
    require(patients[msg.sender].exist,'Patient Not Registered');

    uint  count = doctersArray.length;

    address[] memory dataList = new address[](count);

    for( uint i = 0 ; i < getDoctersCount() ; i++){

      if(patients[msg.sender].docters[doctersArray[i]].viewOnly){

        dataList[i] = doctersArray[i];
      }
    }
    return dataList;

  }

  function getDoctersWithCreateOnlyAccess() public view  returns(address[] memory ) { // patients can get all docter that have their create record access
    require(patients[msg.sender].exist,'Patient Not Registered');

    uint  count = doctersArray.length;

    address[] memory dataList = new address[](count);

    for( uint i = 0 ; i < getDoctersCount() ; i++){

      if(patients[msg.sender].docters[doctersArray[i]].createOnly){

        dataList[i] = doctersArray[i];
      }
    }
    return dataList;
  }


  function getPatients(address _addr) public view returns(string memory _name,string memory _DOB,string memory _gender) {
    require(patients[_addr].exist,'Patient record does not exist.Please register first!!');
    require(patients[_addr].docters[msg.sender].viewOnly || _addr == msg.sender,'Do not has view access !!');

    _name = patients[_addr].name;
    _gender = patients[_addr].gender;
    _DOB = patients[_addr].DOB;

  }


  function getPatientsRecordsCount(address _addr) public view returns(uint count) {  // can be viewed by patient himself and docter who has view access
    require(patients[_addr].exist,'Patient record does not exist.Please register first!!');
    require(patients[_addr].docters[msg.sender].viewOnly ||  _addr == msg.sender,'Do not has view access  !!');
    return patients[_addr].records.length;
  }

  function getPatientsRecords(address _addr,uint256 index) public view returns(string memory _prescriptionData,
    address _docterAddress,string memory _docterName,string memory _visitDate,string memory _additionalNotes,string memory _fromPlace) {   // can be viewed by patient himself and docter who has view access
    require(patients[_addr].exist,'Patient record does not exist.Please register first!!');
    require(patients[_addr].docters[msg.sender].viewOnly || _addr == msg.sender,'Do not has view access !!');

    _prescriptionData =  patients[_addr].records[index].prescriptionData;
    _docterAddress =  patients[_addr].records[index].docterAddress;
    _docterName =  docters[_docterAddress].name;
    _visitDate =  patients[_addr].records[index].visitDate;
    _additionalNotes =  patients[_addr].records[index].additionalNotes;
    _fromPlace =  patients[_addr].records[index].fromPlace;
  }


}
