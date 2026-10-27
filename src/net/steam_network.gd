class_name SteamNetwork
extends INetwork


func start_host(_port: int) -> int:
	return ERR_UNAVAILABLE


func start_client(_address: String, _port: int) -> int:
	return ERR_UNAVAILABLE
