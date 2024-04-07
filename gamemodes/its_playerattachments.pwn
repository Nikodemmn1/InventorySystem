Its_DetachFromPlayer(dbID)
{
    new uid = Its_Get(dbID, ITS_ATP_UID);

    if(itsNotExist)
    {
        return ITS_ITEM_NOT_ATTACHED;
    }

    new index = Its_Get(dbID, ITS_ATP_INDEX);
    new playerid = map_get(UIDtoPlayerID, uid);

    RemovePlayerAttachedObject(playerid, index);

    Its_Set(dbID, ITS_ATP_ISACTIVE, false);
    Its_Set(dbID, ITS_ATP_INDEX, ITS_NULL);

    return 1;
}

Its_ResetPActiveAttachment(dbID)
{
    new uid = Its_Get(dbID, ITS_ATP_UID);
    new playerid = map_get(UIDtoPlayerID, uid);
    new index = Its_Get(dbID, ITS_ATP_INDEX);
    new modelid = Its_Get(dbID, ITS_CL_IC_MODELID);
    new bone = Its_Get(dbID, ITS_ATP_BONE);
    new Float:x = Its_Get(dbID, ITS_ATP_X);
    new Float:y = Its_Get(dbID, ITS_ATP_Y);
    new Float:z = Its_Get(dbID, ITS_ATP_Z);
    new Float:rx = Its_Get(dbID, ITS_ATP_RX);
    new Float:ry = Its_Get(dbID, ITS_ATP_RY);
    new Float:rz = Its_Get(dbID, ITS_ATP_RZ);
    new Float:sx = Its_Get(dbID, ITS_ATP_SX);
    new Float:sy = Its_Get(dbID, ITS_ATP_SY);
    new Float:sz = Its_Get(dbID, ITS_ATP_SZ);

    SetPlayerAttachedObject(playerid, index, modelid, bone, x, y, z, rx, ry, rz, sx, sy, sz);

    return 1;
}

Its_EditPlayerAttachment(dbID, bone, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, Float:rx = 0.0, Float:ry = 0.0, Float:rz = 0.0, Float:sx = 1.0, Float:sy = 1.0, Float:sz = 1.0)
{
    new uid = Its_Get(dbID, ITS_ATP_UID);
    new playerid = map_get(UIDtoPlayerID, uid);
    new modelid = Its_Get(dbID, ITS_CL_IC_MODELID);

    Its_Set(dbID, ITS_ATP_X, x);
    Its_Set(dbID, ITS_ATP_Y, y);
    Its_Set(dbID, ITS_ATP_Z, z);
    Its_Set(dbID, ITS_ATP_RX, rx);
    Its_Set(dbID, ITS_ATP_RY, ry);
    Its_Set(dbID, ITS_ATP_RZ, rz);
    Its_Set(dbID, ITS_ATP_SX, sx);
    Its_Set(dbID, ITS_ATP_SY, sy);
    Its_Set(dbID, ITS_ATP_SZ, sz);
    Its_Set(dbID, ITS_ATP_BONE, bone);

    if(Its_Get(dbID, ITS_ATP_ISACTIVE))
    {
        new index = Its_Get(dbID, ITS_ATP_INDEX);
        SetPlayerAttachedObject(playerid, index, modelid, bone, x, y, z, rx, ry, rz, sx, sy, sz);
    }

    return 1;
}

Its_ReattachToPlayer(dbID)
{
    new uid = Its_Get(dbID, ITS_ATP_UID);
    new playerid = map_get(UIDtoPlayerID, uid);

	new index = GetFreeAttachedObjectSlot(playerid);
	if(index == INVALID_ATTACHED_OBJECT_INDEX)
    {
        return INVALID_ATTACHED_OBJECT_INDEX;
    }

    Its_Set(dbID, ITS_ATP_ISACTIVE, true);
    Its_Set(dbID, ITS_ATP_INDEX, index);

    Its_ResetPActiveAttachment(dbID);

    return 1;
}

Its_AttachToPlayer(dbID, uid, bone, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, Float:rx = 0.0, Float:ry = 0.0, Float:rz = 0.0, Float:sx = 1.0, Float:sy = 1.0, Float:sz = 1.0)
{
    new oldUid = Its_Get(dbID, ITS_ATP_UID);
    new playerid = map_get(UIDtoPlayerID, uid);

    if(!itsNotExist)
    {
        if(oldUid == uid)
        {
            Its_ReattachToPlayer(dbID);
            Its_EditPlayerAttachment(dbID, bone, x, y, z, rx, ry, rz, sx, sy, sz);
            return 1;
        }

        Its_DetachFromPlayer(dbID);
    }

	new index = GetFreeAttachedObjectSlot(playerid);
	if(index == INVALID_ATTACHED_OBJECT_INDEX)
    {
        return INVALID_ATTACHED_OBJECT_INDEX;
    }

    if(itsNotExist)
    {
        new modelid = Its_Get(dbID, ITS_CL_IC_MODELID);
        Its_Create_ATP(dbID, uid, x, y, z, rx, ry, rz, sx, sy, sz, bone, true, index);
        SetPlayerAttachedObject(playerid, index, modelid, bone, x, y, z, rx, ry, rz, sx, sy, sz); 
    }
    else
    {
        Its_Set(dbID, ITS_ATP_ISACTIVE, true);
        Its_Set(dbID, ITS_ATP_INDEX, index);
        Its_EditPlayerAttachment(dbID, bone, x, y, z, rx, ry, rz, sx, sy, sz);
    }

	return index;
}

CheckAttachEditBoundariesTmp(playerid, Float:x, Float:y, Float:z, Float:sx, Float:sy, Float:sz)
{
	if(-0.5 > x || x > 0.5) 
	{ 
		SendClientMessage(playerid, COLOR_WHITE, "Ten obiekt wykracza poza granice w osi X!");
		return 0;
	}
	if(-0.5 > y || y > 0.5) 
	{ 
		SendClientMessage(playerid, COLOR_WHITE, "Ten obiekt wykracza poza granice w osi Y!");
		return 0;
	}
	if(-0.5 > z || z > 0.5) 
	{ 
		SendClientMessage(playerid, COLOR_WHITE, "Ten obiekt wykracza poza granice w osi Z!");
		return 0;
	}

	if(0.5 > sx || sx > 1.5) 
	{
		SendClientMessage(playerid, COLOR_WHITE, "Ten obiekt jest za du¿y w skali X!");
		return 0;
	} 
	if(0.5 > sy || sy > 1.5) 
	{
		SendClientMessage(playerid, COLOR_WHITE, "Ten obiekt jest za du¿y w skali Y!");
		return 0;
	} 
	if(0.5 > sz || sz > 1.5) 
	{
		SendClientMessage(playerid, COLOR_WHITE, "Ten obiekt jest za du¿y w skali Z!");
		return 0;
	} 
	return 1;
}

GetFreeAttachedObjectSlot(playerid)
{
	for(new i; i<MAX_PLAYER_ATTACHED_OBJECTS; i++) 
	{
		if(!IsPlayerAttachedObjectSlotUsed(playerid, i))
		{
			return i;
		}
	}
	return INVALID_ATTACHED_OBJECT_INDEX; 
}