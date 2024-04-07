#include <YSI\y_hooks>

hook OnPlayerEditAttachedObj(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
    new dbID;
    new uid = map_get(playerIDToUID, playerid);

    //TODO: zmieni� to w co� sensowniejszego przy integracji (attachmenty przypisane do gracza)
    for(new Iter:icIter=map_iter(itsCategoriesByTag["ATP"][ITS_IDXMAP]);iter_inside(icIter);iter_move_next(icIter))
    {
        dbID = iter_get_key(icIter);
        if(Its_Get(dbID, ITS_ATP_UID) == uid && Its_Get(dbID, ITS_ATP_ISACTIVE) && Its_Get(dbID, ITS_ATP_INDEX) == index)
        {
            break;
        }
        else
        {
            dbID = ITS_NULL;
        }
    }

    if(dbID == ITS_NULL)
    {
        return Y_HOOKS_CONTINUE_RETURN_1;
    }

    if(!response)
    {
        SendClientMessage(playerid, COLOR_RED, "Anulowa�e� edycj� pozycj� swojego przedmiotu.");
        Its_ResetPActiveAttachment(dbID);
        return Y_HOOKS_BREAK_RETURN_0;
    }

    if(!CheckAttachEditBoundariesTmp(playerid, fOffsetX, fOffsetY, fOffsetZ, fScaleX, fScaleY, fScaleZ)) // TODO: zmien na normalna wersje przy integracji
    {
        EditAttachedObject(playerid, index);
        //TODO: je�eli gracz kliknie wyjdz 2 razy w kr�tkim czasie, nie w�aczy mu si� edycja
        return Y_HOOKS_BREAK_RETURN_0;
    }

    SendClientMessage(playerid, COLOR_GREEN, "Edytowa�e� pozycj� swojego przedmiotu.");
    Its_EditPlayerAttachment(playerid, boneid, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ);

    return Y_HOOKS_BREAK_RETURN_0;
}

hook OnPlayerSpawn(playerid)
{
    new uid = map_get(playerIDToUID, playerid);

    //TODO: zmieni� to w co� sensowniejszego przy integracji (attachmenty przypisane do gracza)
    for(new Iter:icIter=map_iter(itsCategoriesByTag["ATP"][ITS_IDXMAP]);iter_inside(icIter);iter_move_next(icIter))
    {
        new dbID = iter_get_key(icIter);
        if(Its_Get(dbID, ITS_ATP_UID) == uid && Its_Get(dbID, ITS_ATP_ISACTIVE))
        {
            Its_ResetPActiveAttachment(dbID);
        }
    }
}
