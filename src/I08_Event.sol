interface I08_Event {
	event ValueChanged(uint256 indexed);
	function getValue() external view returns (uint256);
	function setValue(uint256) external;
}