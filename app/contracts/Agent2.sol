pragma solidity ^0.5.1;

contract Agent {
    
    struct patient {
        string name;
        uint age;
        string photo; // URL or IPFS hash of the patient's photo
        string aadhar;
        string bloodtype;
        string insurance;
        string provider;
        string address;
        string contact;
        string patientmail;
        address[] doctorAccessList;
        uint[] diagnosis;
        string record;
    }
    
    struct doctor {
        string name;
        uint age;
        string photo; // URL or IPFS hash of the doctor's photo
        string qualification;
        string posting;
        string department;
        uint experience;
        string doctormail;
        address[] patientAccessList;
    }

    uint creditPool;

    address[] public patientList;
    address[] public doctorList;

    mapping (address => patient) patientInfo;
    mapping (address => doctor) doctorInfo;
    mapping (address => address) Empty;
    mapping (address => string) patientRecords;
    


    function add_agent(string memory _name, uint _age, uint _designation, string memory _hash) public returns(string memory){
        address addr = msg.sender;
        
        if(_designation == 0){
            patient memory p;
            p.name = _name;
            p.age = _age;
            patientInfo[addr].photo = _photo;
            patientInfo[addr].aadharNumber = _aadhar;
            patientInfo[addr].bloodtype = _bloodtype;
            patientInfo[addr].healthInsuranceNumber = _insurance;
            patientInfo[addr].healthInsurerName = _provider;
            patientInfo[addr].address = _address;
            patientInfo[addr].contactNumber = _contact;
            patientInfo[addr].email = _patientmmail;            
            p.record = _hash;
            patientInfo[msg.sender] = p;
            patientList.push(addr)-1;
            return _name;
        }
        
       else if (_designation == 1){
            doctorInfo[addr].name = _name;
            doctorInfo[addr].age = _age;
            doctorInfo[addr].photo = _photo;
            doctorInfo[addr].qualification = _qualification;
            doctorInfo[addr].designation = _posting;
            doctorInfo[addr].department = _department;
            doctorInfo[addr].yearsOfExperience = _experience;
            doctorInfo[addr].email = _doctormmail;
            doctorList.push(addr)-1;
            return _name;
       }
       else{
           revert();
       }
    }


    function get_patient(address addr) view public returns (string memory, uint, string memory, string memory, string memory, string memory, string memory, string memory) {
        return (
            patientInfo[addr].name,
            patientInfo[addr].age,
            patientInfo[addr].photo,
            patientInfo[addr].aadhar,
            patientInfo[addr].bloodtype,
            patientInfo[addr].insurance,
            patientInfo[addr].provider,
            patientInfo[addr].address,
            patientInfo[addr].contact,
            patientInfo[addr].patientmail;
        )
    }

    function get_doctor(address addr) view public returns (string memory, uint, string memory, string memory, string memory, uint, string memory, string memory) {
        return (
            doctorInfo[addr].name,
            doctorInfo[addr].age,
            doctorInfo[addr].photo,
            doctorInfo[addr].qualification,
            doctorInfo[addr].posting,
            doctorInfo[addr].department,
            doctorInfo[addr].experience,
            doctorInfo[addr].doctormail
        );
    }
    function get_patient_doctor_name(address paddr, address daddr) view public returns (string memory , string memory ){
        return (patientInfo[paddr].name,doctorInfo[daddr].name);
    }

    function permit_access(address addr) payable public {
        require(msg.value == 2 ether);

        creditPool += 2;
        
        doctorInfo[addr].patientAccessList.push(msg.sender)-1;
        patientInfo[msg.sender].doctorAccessList.push(addr)-1;
        
    }


    //must be called by doctor
    function insurance_claim(address paddr, uint _diagnosis, string memory  _hash) public {
        bool patientFound = false;
        for(uint i = 0;i<doctorInfo[msg.sender].patientAccessList.length;i++){
            if(doctorInfo[msg.sender].patientAccessList[i]==paddr){
                msg.sender.transfer(2 ether);
                creditPool -= 2;
                patientFound = true;
                
            }
            
        }
        if(patientFound==true){
            set_hash(paddr, _hash);
            remove_patient(paddr, msg.sender);
        }else {
            revert();
        }

        bool DiagnosisFound = false;
        for(uint j = 0; j < patientInfo[paddr].diagnosis.length;j++){
            if(patientInfo[paddr].diagnosis[j] == _diagnosis)DiagnosisFound = true;
        }
    }

    function remove_element_in_array(address[] storage Array, address addr) internal returns(uint)
    {
        bool check = false;
        uint del_index = 0;
        for(uint i = 0; i<Array.length; i++){
            if(Array[i] == addr){
                check = true;
                del_index = i;
            }
        }
        if(!check) revert();
        else{
            if(Array.length == 1){
                delete Array[del_index];
            }
            else {
                Array[del_index] = Array[Array.length - 1];
                delete Array[Array.length - 1];

            }
            Array.length--;
        }
    }

    function remove_patient(address paddr, address daddr) public {
        remove_element_in_array(doctorInfo[daddr].patientAccessList, paddr);
        remove_element_in_array(patientInfo[paddr].doctorAccessList, daddr);
    }
    
    function get_accessed_doctorlist_for_patient(address addr) public view returns (address[] memory )
    { 
        address[] storage doctoraddr = patientInfo[addr].doctorAccessList;
        return doctoraddr;
    }
    function get_accessed_patientlist_for_doctor(address addr) public view returns (address[] memory )
    {
        return doctorInfo[addr].patientAccessList;
    }

    
    function revoke_access(address daddr) public payable{
        remove_patient(msg.sender,daddr);
        msg.sender.transfer(2 ether);
        creditPool -= 2;
    }

    function get_patient_list() public view returns(address[] memory ){
        return patientList;
    }

    function get_doctor_list() public view returns(address[] memory ){
        return doctorList;
    }

    function get_hash(address paddr) public view returns(string memory ){
        return patientInfo[paddr].record;
    }

    function set_hash(address paddr, string memory _hash) internal {
        patientInfo[paddr].record = _hash;
    }

}

