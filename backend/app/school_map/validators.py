def validate_chat_json(received_json):
    if 'anonIdentifier' not in received_json:
        return False
    if 'chat_content' not in received_json:
        return False
    if type(received_json['chat_content']) is not str and received_json['chat_content'] is not None:
        return False
    # if type(received_json['anonIdentifier']) is not str:
    #     return False

    return True


def validate_nearest_json(received_json):
    if 'anonIdentifier' not in received_json:
        return False
    if 'nearest' not in received_json:
        return False
    if type(received_json['anonIdentifier']) is not str:
        return False
    if type(received_json['nearest']) is not int and received_json['nearest'] is not None:
        return False

    return True


def validate_precise_location_json(received_json):
    if 'anonIdentifier' not in received_json:
        return False
    if 'beacons' not in received_json:
        return False
    if type(received_json['anonIdentifier']) is not str:
        return False
    if type(received_json['beacons']) is not list:
        return False
    for beacon in received_json['beacons']:
        if type(beacon) is not dict:
            return False
        if 'minor' not in beacon:
            return False
        if 'distance' not in beacon:
            return False
        if type(beacon['minor']) is not int:
            return False
        if type(beacon['distance']) is not float:
            return False

    return True
