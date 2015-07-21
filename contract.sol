contract BoardRoom {
    function getProposalBytes(uint _pid,bytes32 _param) returns (bytes32 b){}
    function getProposalUint(uint256 _pid,bytes32 _param) returns (uint256 u){}
    function getProposalExecuted(uint256 _pid) returns (bool b){}
    function hasWon(uint256 _pid) returns (bool ){}
    
    
    function getDelegationNumDelegations(uint256 _pid,uint256 _to) returns (uint256 u){}
    function getDelegationType(uint256 _pid,uint256 _to) returns (bool b){}
    
    
    function getMemberUint(uint256 _mid,bytes32 _param) returns (uint256 u){}
    function numMembersActive() constant returns (uint256 ){}
    function getMemberAddress(uint256 _mid) returns (address a){}
    function toMember(address ) constant returns (uint256 ){}
    function chair() constant returns (uint256 ){}
    
    
    function numExecuted() constant returns (uint256 ){}
    function numProposals() constant returns (uint256 ){}
    function numMembers() constant returns (uint256 ){}
    function numChildrenActive() constant returns (uint256 ){}
    function numChildren() constant returns (uint256 ){}
    function configAddr() constant returns (address ){}
    
    
    function parent() constant returns (address ){}
    function children(uint256 ) constant returns (address ){}
}


contract String{
    function parseDecimal(bytes32 byteString) returns (uint256 r){}
    function charAt(bytes32 b,uint256 char) returns (bytes1 ){}
}

contract Payroll {
    struct SalaryInstance {
        address addr;
        uint salary;
    }
    
    struct PayrollInstance {
        uint instanceExpiry;
        uint created;
        uint payed;
        uint numSalaries;
        uint totalPayout;
        mapping(address => uint) toSalary;
        mapping(uint => SalaryInstance) salaries;
    }
    
    mapping(address => mapping(address => uint)) numPayrolls;
    mapping(address => mapping(address => mapping(uint => PayrollInstance))) payrolls;
    
    function addPayroll(address _boardroomAddress) {
        uint _numPayrolls = numPayrolls[msg.sender][_boardroomAddress];
        PayrollInstance p = payrolls[msg.sender][_boardroomAddress][_numPayrolls];
        
        if(p.created != 0 || p.payed != 0 || p.numSalaries != 0)
            return;
            
        p.created = now;
        numPayrolls[msg.sender][_boardroomAddress] += 1;
        p.instanceExpiry = now + (180 days);
    }
    
    function removePayroll(address _boardroomAddress, uint _payrollId) {
        PayrollInstance p = payrolls[msg.sender][_boardroomAddress][_payrollId];
        
        if(p.created == 0 || p.payed != 0 || p.instanceExpiry < now)
            return;
            
        delete numPayrolls[msg.sender][_boardroomAddress];
        delete payrolls[msg.sender][_boardroomAddress][_payrollId];
    }
    
    function addSalary(address _boardroomAddress, uint _payrollId, address _payee, uint _salary) {
        PayrollInstance p = payrolls[msg.sender][_boardroomAddress][_payrollId];
        
        if(p.created == 0 || p.payed != 0 || p.salaries[p.numSalaries].salary != 0 || _salary == 0)
            return;
        
        SalaryInstance s = p.salaries[p.numSalaries]; 
        s.addr = _payee;
        s.salary = _salary;
        p.toSalary[_payee] = p.numSalaries;
        p.numSalaries++;
        p.totalPayout += _salary;
    }
    
    address stringAddress = address(0);
    
    function execute(uint _pid) {
        address boardroomAddress = msg.sender;
        
        uint proposalFrom = BoardRoom(boardroomAddress).getProposalUint(_pid, "from");
        bytes32 proposalData = BoardRoom(boardroomAddress).getProposalBytes(_pid, "value");
        uint payoutId = String(stringAddress).parseDecimal(proposalData);
        address memberAddress = BoardRoom(boardroomAddress).getMemberAddress(proposalFrom);
        
        PayrollInstance p = payrolls[memberAddress][boardroomAddress][payoutId];
        
        if(p.created > now || p.created == 0 || p.numSalaries == 0 || p.payed != 0 || msg.value < p.totalPayout)
            return;
            
        for(uint pid = 0; pid < p.numSalaries; pid++){
            p.salaries[pid].addr.send(p.salaries[pid].salary);
        }
        
        p.payed = now;
    }
}             


/*
contract Payroll{function addSalary(address _boardroomAddress,uint256 _payrollId,address _payee,uint256 _salary){}function removePayroll(address _boardroomAddress,uint256 _payrollId){}function addPayroll(address _boardroomAddress){}function execute(uint256 _pid){}}


600280547fffffffffffffffffffffffff0000000000000000000000000000000000000000169055610635806100366000396000f3007c0100000000000000000000000000000000000000000000000000000000600035046316edf5c3811461004f57806341b26b261461017757806389baa7731461025d578063fe0d94c11461033157005b73ffffffffffffffffffffffffffffffffffffffff33811660009081526001602081815260408084206004359586168552825280842060243580865292528320918201546103bf949391926044359260643592819082908314806100b857506002840154600014155b806100da57506003840154600090815260068501602052604081206001015414155b806100e55750846000145b61062b575b50506003820180546000908152600684016020908152604080832080547fffffffffffffffffffffffff000000000000000000000000000000000000000016891781556001808201899055855473ffffffffffffffffffffffffffffffffffffffff8b168652600589019094529184208390559101909255600484018054860190555b5050505050505050565b73ffffffffffffffffffffffffffffffffffffffff33811660009081526001602081815260408084206004359586168552825280842060243580865292528320918201546103c59493919291908114806101d657506002820154600014155b806101e2575081544290105b610630575b73ffffffffffffffffffffffffffffffffffffffff3381166000818152602081815260408083209489168084529482528083208390559282526001808252838320948352938152828220878352905290812081815591820181905560028201819055600382018190556004909101555b50505050565b73ffffffffffffffffffffffffffffffffffffffff3381166000818152602081815260408083206004359586168085529083528184205494845260018084528285209185529083528184208585529092528220908101546103cb94939290811415806102ce57506002820154600014155b806102de57506003820154600014155b6103d7575b42600180840182905573ffffffffffffffffffffffffffffffffffffffff338116600090815260208181526040808320938a168352929052208054909101905562ed4e000182555b50505050565b7f5ca9a4d500000000000000000000000000000000000000000000000000000000600090815260048035908190527f66726f6d000000000000000000000000000000000000000000000000000000006024526103d191339080818283848573ffffffffffffffffffffffffffffffffffffffff8816635ca9a4d560208960448b8c866161da5a03f16103ee57005b60006000f35b60006000f35b60006000f35b60006000f35b61032b565b4260028401555b505050505050505050565b5050600080517f0c4f284200000000000000000000000000000000000000000000000000000000825260048b90527f76616c7565000000000000000000000000000000000000000000000000000000602452975073ffffffffffffffffffffffffffffffffffffffff891690630c4f28429060209060448182866161da5a03f161047457005b5050600080516002547fa052b596000000000000000000000000000000000000000000000000000000008352600482905290975073ffffffffffffffffffffffffffffffffffffffff169063a052b5969060209060248182866161da5a03f16104d957005b505060005194508773ffffffffffffffffffffffffffffffffffffffff16639029444a60206000827c01000000000000000000000000000000000000000000000000000000000260005260048b815260200160006000866161da5a03f161053c57005b50506000805173ffffffffffffffffffffffffffffffffffffffff8082168352600160208181526040808620938e1686529281528285208a8652905290832090810154919650945090925042901180610599575060018301546000145b806105a8575060038301546000145b806105b857506002830154600014155b806105c65750600483015434105b61061b575b5060005b60038301548110156103dc5760008181526006840160205260408120805460019091015473ffffffffffffffffffffffffffffffffffffffff909116919081828384848787f161062057005b6103e3565b5050506001016105cf565b61016d565b61025756

[
  {
    "constant": false,
    "inputs": [
      {
        "name": "_boardroomAddress",
        "type": "address"
      },
      {
        "name": "_payrollId",
        "type": "uint256"
      },
      {
        "name": "_payee",
        "type": "address"
      },
      {
        "name": "_salary",
        "type": "uint256"
      }
    ],
    "name": "addSalary",
    "outputs": [],
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_boardroomAddress",
        "type": "address"
      },
      {
        "name": "_payrollId",
        "type": "uint256"
      }
    ],
    "name": "removePayroll",
    "outputs": [],
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_boardroomAddress",
        "type": "address"
      }
    ],
    "name": "addPayroll",
    "outputs": [],
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_pid",
        "type": "uint256"
      }
    ],
    "name": "execute",
    "outputs": [],
    "type": "function"
  }
]


*/
