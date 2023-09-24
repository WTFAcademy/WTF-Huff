interface I09_Error {
	error CustomError(uint256);
	function getError() external view returns (uint256);
}