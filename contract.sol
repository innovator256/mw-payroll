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

/// @title Payroll Middleware
/// @author Nick Dodson
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
    
    /// @notice Add a PayRoll instance from your member address to a BoardRoom address.
    /// The payroll instance allows you to add salaries to the payroll.
    /// @dev The add payroll method will create a stored instance of a payroll in which
    /// a board member can add salaries with the addSalary method.
    /// @param _boardroomAddress The address of the BoardRoom
    function addPayroll(address _boardroomAddress) {
        uint _numPayrolls = numPayrolls[msg.sender][_boardroomAddress];
        PayrollInstance p = payrolls[msg.sender][_boardroomAddress][_numPayrolls];
        
        if(p.created != 0 || p.payed != 0 || p.numSalaries != 0)
            return;
            
        p.created = now;
        numPayrolls[msg.sender][_boardroomAddress] += 1;
        p.instanceExpiry = now + (180 days);
    }
    
    /// @notice This method will remove a payroll instance
    /// @dev This method will remove a boardroom instance at a specific payroll id from contract storage.
    /// Only the member who proposed the payroll isntance can remove it and only after the instance has
    /// expired.
    /// @param _boardroomAddress The address of the BoardRoom
    /// @param _payrollId The ID of the payroll instance
    function removePayroll(address _boardroomAddress, uint _payrollId) {
        PayrollInstance p = payrolls[msg.sender][_boardroomAddress][_payrollId];
        
        if(p.created == 0 || p.payed != 0 || p.instanceExpiry < now)
            return;
            
        delete numPayrolls[msg.sender][_boardroomAddress];
        delete payrolls[msg.sender][_boardroomAddress][_payrollId];
    }
    
    /// @notice This method will add a salary to a payroll. Here a board member can specify an address and salary
    /// to be payed out that address.
    /// @dev This will add a salary instance to a payroll instance.
    /// @param _boardroomAddress The address of the BoardRoom
    /// @param _payrollId The ID of the payroll instance
    /// @param _payee The salary receiver
    /// @param _salary The salary in Wei units
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
