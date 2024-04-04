#include <YSI\y_hooks>

Its_EquipmentMenu_Handle(playerid, response, const inputtext[])
{
    new dbID;

    if(!response || ppContID == ITS_NULL)
    {
        return Y_HOOKS_CONTINUE_RETURN_1;
    }

    if(strgetfirstc(inputtext) == '*' || strgetfirstc(inputtext) == ' ')
    {            
        Its_ShowEquipment(playerid, itsChosenPickUpMenu[playerid]);
        return Y_HOOKS_CONTINUE_RETURN_1;
    }

    printf(inputtext);
    if(strfind(inputtext, ">>       ") == 0) // >>Wyrzuæ
    {
        new Float:x, Float:y, Float:z, interior, vw;
        GetPlayerPos(playerid, x, y, z);
        interior = GetPlayerInterior(playerid);
        vw = GetPlayerVirtualWorld(playerid);

        new unplacableInside = false;
        new List:itemList = List:Its_Get(ppContID, ITS_BC_CONT_ITEMS);
        for(new i = 0; i < list_size(itemList); i++)
        {
            dbID = list_get(itemList, i);
            if(map_has_key(itsChosenPickUpMenu[playerid], dbID))
            {
                if(!Its_Get(dbID, ITS_CL_IC_ISPLACEABLE))
                {
                    unplacableInside = true;
                    continue;
                }

                Its_Place_Item(dbID, x, y, z, interior, vw, ITS_NULL); //TODO: ownerID zmieniæ na coœ poprawnego
                i--; // bo wywaliliœmy przedmiot z listy
            }
        }

        if(!unplacableInside)
        {
            SendClientMessage(playerid, COLOR_WHITE, "Wybrane przedmioty zosta³y wyrzucone na ziemiê.");
        }
        else
        {
            SendClientMessage(playerid, COLOR_WHITE, "Czêœæ przedmiotów nie mog³a zostaæ wyrzucona (nie mo¿na ich umieszczaæ).");
        }

        Streamer_Update(playerid);

        return Y_HOOKS_CONTINUE_RETURN_1;
    }

    sscanf(inputtext, "d", dbID);

    if(map_has_key(itsChosenPickUpMenu[playerid], dbID))
    {
        map_remove(itsChosenPickUpMenu[playerid], dbID);
    }
    else
    {
        map_add(itsChosenPickUpMenu[playerid], dbID, true);
    }

    Its_ShowEquipment(playerid, itsChosenPickUpMenu[playerid]);

    return Y_HOOKS_CONTINUE_RETURN_1;
}

Its_ShowEquipment(playerid, Map:menuMap)
{
    new itemID, name[ITS_FRIENDLYNAME_SIZE], itemSize, isEquippedStr[8];
    new dialogInfo[100*256];
    format(dialogInfo, sizeof(dialogInfo), "ID\tNazwa\tRozmiar\tZa³o¿ony\n");
    new List:itemsList = List:Its_Get(ppContID, ITS_BC_CONT_ITEMS);
    
    for(new i = 0; i < list_size(itemsList); i++)
    {
        itemID = list_get(itemsList, i);
        Its_GetArr(itemID, ITS_CL_IC_FRIENDLYNAME, name, sizeof(name));
        itemSize = Its_Get(itemID, ITS_CL_BI_ITEMSIZE);
        isEquippedStr = " ";

        if(Its_Get(itemID, ITS_BI_ISEQUIPPED))
        {
            isEquippedStr = "TAK";
        }

        if(map_has_key(menuMap, itemID))
        {
            format(dialogInfo, sizeof(dialogInfo), "%s{33AA33}%d\t{33AA33}%s\t{33AA33}%d\t{33AA33}%s\n", dialogInfo, itemID, name, itemSize, isEquippedStr);
        }
        else
        {
            format(dialogInfo, sizeof(dialogInfo), "%s%d\t%s\t%d\t%s\n", dialogInfo, itemID, name, itemSize, isEquippedStr);
        }
    }

    format(dialogInfo, sizeof(dialogInfo), 
        "%s         \t \t \t \n\
        {33CCFF}**\t{33CCFF}Zajêtoœæ ekwipunku:\t{33CCFF}[%d/%d]\t \n", 
        dialogInfo, Its_Get(ppContID, ITS_BC_TAKEN_SPACE), Its_Get(ppContID, ITS_CL_BC_CONTAINERSIZE));

    if(map_size(menuMap) != 0)
    {
        format(dialogInfo, sizeof(dialogInfo), "%s{FF9900}>>       \t{FF9900}Wyrzuæ\t \t \n", dialogInfo);
    }

    ShowPlayerDialog(playerid, ITS_EQUIPMENT_DIALID, DIALOG_STYLE_TABLIST_HEADERS, "Twój ekwipunek", dialogInfo, "OK", "ANULUJ");
    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == ITS_EQUIPMENT_DIALID)
    {
        return Its_EquipmentMenu_Handle(playerid, response, inputtext);
    }

    return Y_HOOKS_CONTINUE_RETURN_0;
}

YCMD:eq(playerid, params[], help)
{
    new query[1000], nick[MAX_PLAYER_NAME], rowString[2048];
    GetPlayerName(playerid, nick);
    format(query, 1000, "SELECT pc.ID FROM `mru_player_containers` pc JOIN `mru_konta` mk ON pc.PLAYERUID = mk.UID WHERE mk.Nick = '%s'", nick);
    mysql_query(query);
    mysql_store_result();
    mysql_fetch_row_format(rowString, "|");
    sscanf(rowString, "d", ppContID);
    mysql_free_result();

    if(map_valid(itsChosenPickUpMenu[playerid]))
    {
        map_clear(itsChosenPickUpMenu[playerid]);
    }
    else
    {
        itsChosenPickUpMenu[playerid] = map_new();
    }

    Its_ShowEquipment(playerid, itsChosenPickUpMenu[playerid]);
    return 1;
}