interface I16_Ownable {
	event OwnerUpdated(address indexed, address indexed);
	function changeOwner(address) external;
	function owner() external view returns (address);
}