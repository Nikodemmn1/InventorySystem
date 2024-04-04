#include <YSI\y_hooks>
new ppContID = -1; //TODO: WYWAL!!!!

Its_PickupContVarDial_Handle(playerid, response, listitem)
{
    if(!response)
    {
        return Y_HOOKS_CONTINUE_RETURN_1;
    }

    new containerID = itsChosenContainerID[playerid];

    if(listitem == 1)
    {
        if(map_valid(itsChosenPickUpMenu[playerid]))
        {
            map_clear(itsChosenPickUpMenu[playerid]);
        }
        else
        {
            itsChosenPickUpMenu[playerid] = map_new();
        }

        itsChosenSelectedSize[playerid] = 0;
        Its_ShowPickupChooseDialog(playerid, containerID, itsChosenPickUpMenu[playerid]);
    }
    else
    {
        new pEqTakenSpace = Its_Get(ppContID, ITS_BC_TAKEN_SPACE);
        new containerTakenSpace = Its_Get(containerID, ITS_BC_TAKEN_SPACE);
        new containerSize = Its_Get(ppContID, ITS_CL_BC_CONTAINERSIZE);
        new totalSize = pEqTakenSpace + containerTakenSpace;

        if(listitem == 0)
        {
            new emptyItemClass = Its_Get(containerID, ITS_CL_BC_EMPTYITEMCLASS);
            
            if(emptyItemClass == ITS_NULL)
            {
                SendClientMessage(playerid, COLOR_WHITE, "Tego pojemnika nie mo¿na podnieœæ.");
                return Its_PickupContVarDial_Handle(playerid, response, 2);
            }

            new emptyItemSize = itsClassesBI[emptyItemClass][ITS_CL_BI_ITEMSIZE];
            totalSize += emptyItemSize;
        }

        if(pEqTakenSpace + containerTakenSpace > containerSize)
        {
            SendClientMessage(playerid, COLOR_WHITE, "Masz za ma³o miejsca w ekwipunku. Wybierz, które przedmioty chcesz wzi¹æ.");
            return Its_PickupContVarDial_Handle(playerid, response, 1);
        }

        new successMessage[256] = "Przenios³eœ do wyposa¿enia wszystkie przedmioty z pojemnika.";

        Its_MoveAllBetweenContainers(containerID, ppContID);

        if(listitem == 0)
        {
            Its_Container_To_Empty_Item(containerID, ppContID);
            successMessage[strlen(successMessage) - 1] = 0;
            format(successMessage, sizeof(successMessage), "%s oraz sam pojemnik.", successMessage);
        }

        SendClientMessage(playerid, COLOR_WHITE, successMessage);
    }

    return Y_HOOKS_CONTINUE_RETURN_1;
}

Its_PickupChooseDial_Handle(playerid, response, const inputtext[])
{
    new containerID = itsChosenContainerID[playerid];
    new dbID;

    if(!response || containerID == ITS_NULL)
    {
        return Y_HOOKS_CONTINUE_RETURN_1;
    }

    if(strgetfirstc(inputtext) == '*' || strgetfirstc(inputtext) == ' ')
    {            
        Its_ShowPickupChooseDialog(playerid, containerID, itsChosenPickUpMenu[playerid]);
        return Y_HOOKS_CONTINUE_RETURN_1;
    }

    if(strgetfirstc(inputtext) == '>')
    {
        if(map_size(itsChosenPickUpMenu[playerid]) == 0)
        {
            return Y_HOOKS_CONTINUE_RETURN_1;
        }

        new List:itemList = List:Its_Get(containerID, ITS_BC_CONT_ITEMS);
        for(new i = 0; i < list_size(itemList); i++)
        {
            dbID = list_get(itemList, i);
            if(map_has_key(itsChosenPickUpMenu[playerid], dbID))
            {
                if(Its_Get(ppContID, ITS_BC_TAKEN_SPACE) + Its_Get(dbID, ITS_CL_BI_ITEMSIZE) > Its_Get(ppContID, ITS_CL_BC_CONTAINERSIZE))
                {
                    break;
                }

                Its_Move_Item_To_Container(dbID, ppContID);
                i--; // bo wywaliliœmy przedmiot z listy
            }
        }

        SendClientMessage(playerid, COLOR_WHITE, "Wybrane przedmioty zosta³y dodane do twojego ekwipunku.");

        return Y_HOOKS_CONTINUE_RETURN_1;
    }

    sscanf(inputtext, "d", dbID);

    if(map_has_key(itsChosenPickUpMenu[playerid], dbID))
    {
        map_remove(itsChosenPickUpMenu[playerid], dbID);
        itsChosenSelectedSize[playerid] -= Its_Get(dbID, ITS_CL_BI_ITEMSIZE);
    }
    else if(itsChosenSelectedSize[playerid] + Its_Get(ppContID, ITS_BC_TAKEN_SPACE) + Its_Get(dbID, ITS_CL_BI_ITEMSIZE) <= Its_Get(ppContID, ITS_CL_BC_CONTAINERSIZE))
    {
        map_add(itsChosenPickUpMenu[playerid], dbID, true);
        itsChosenSelectedSize[playerid] += Its_Get(dbID, ITS_CL_BI_ITEMSIZE);
    }

    Its_ShowPickupChooseDialog(playerid, containerID, itsChosenPickUpMenu[playerid]);

    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == ITS_PICK_UP_CONTVAR_DIALID)
    {
        return Its_PickupContVarDial_Handle(playerid, response, listitem);
    }

    if(dialogid == ITS_PICK_UP_CHOOSE_DIALID)
    {
        return Its_PickupChooseDial_Handle(playerid, response, inputtext);
    }

    return Y_HOOKS_CONTINUE_RETURN_0;
}

Its_ShowPickupContVariantDialog(playerid, containerID)
{
    new caption[ITS_FRIENDLYNAME_SIZE*2], contName[ITS_FRIENDLYNAME_SIZE];

    Its_GetArr(containerID, ITS_CL_IC_FRIENDLYNAME, contName, ITS_FRIENDLYNAME_SIZE);
    format(caption, sizeof(caption), "Co chcesz zrobiæ z tym pojemnikiem (%s [ID: %d])?", contName, containerID);

    new dialogInfo[3*256] =
        "Przenieœ wszystkie przedmioty z pojemnika do ekwipunku, razem z pustym pojemnikiem\n\
        Wybierz przedmioty, które chcesz zabraæ z pojemnika\n\
        Przenieœ wszystkie przedmioty do ekwipunku, ale pozostaw pojemnik\n";

    ShowPlayerDialog(playerid, ITS_PICK_UP_CONTVAR_DIALID, DIALOG_STYLE_LIST, caption, dialogInfo, "OK", "ANULUJ");
    return 1;
}

Its_ShowPickupChooseDialog(playerid, containerID, Map:menuMap)
{
    if(itsChosenContainerID[playerid] == ITS_NULL)
    {
        //TODO: Mo¿e dodac jakiœ komunikat?
        return 1;
    }

    new itemID, name[ITS_FRIENDLYNAME_SIZE], itemSize;
    new dialogInfo[100*256];
    format(dialogInfo, sizeof(dialogInfo), "ID\tNazwa\tRozmiar\n");
    new List:itemsList = List:Its_Get(containerID, ITS_BC_CONT_ITEMS);
    new selectedItemsSize = itsChosenSelectedSize[playerid];
    
    for(new i = 0; i < list_size(itemsList); i++)
    {
        itemID = list_get(itemsList, i);
        Its_GetArr(itemID, ITS_CL_IC_FRIENDLYNAME, name, sizeof(name));
        itemSize = Its_Get(itemID, ITS_CL_BI_ITEMSIZE);
        if(map_has_key(menuMap, itemID))
        {
            format(dialogInfo, sizeof(dialogInfo), "%s{33AA33}%d\t{33AA33}%s\t{33AA33}%d\n", dialogInfo, itemID, name, itemSize);
        }
        else if(selectedItemsSize + Its_Get(itemID, ITS_CL_BI_ITEMSIZE) + Its_Get(ppContID, ITS_BC_TAKEN_SPACE) > Its_Get(ppContID, ITS_CL_BC_CONTAINERSIZE))
        {
            format(dialogInfo, sizeof(dialogInfo), "%s{FF0000}%d\t{FF0000}%s\t{FF0000}%d\n", dialogInfo, itemID, name, itemSize);
        }
        else
        {
            format(dialogInfo, sizeof(dialogInfo), "%s%d\t%s\t%d\n", dialogInfo, itemID, name, itemSize);
        }
    }

    format(dialogInfo, sizeof(dialogInfo), 
        "%s\t \t \n\
        {33CCFF}**\t{33CCFF}Zajêtoœæ twojego ekwipunku po podniesieniu:\t{33CCFF}[%d/%d]\n\
        {FF9900}>>\t{FF9900}ZatwierdŸ\t \n", 
        dialogInfo, Its_Get(ppContID, ITS_BC_TAKEN_SPACE) + selectedItemsSize, Its_Get(ppContID, ITS_CL_BC_CONTAINERSIZE));

    ShowPlayerDialog(playerid, ITS_PICK_UP_CHOOSE_DIALID, DIALOG_STYLE_TABLIST_HEADERS, "Wybierz przedmioty, które chcesz podnieœæ", dialogInfo, "OK", "ANULUJ");
    return 1;
}

YCMD:podnies(playerid, params[], help)
{
    new strmod[16];
    new dbID, playerContID;
    new Float:x, Float:y, Float:z, Float:distance;
    if(sscanf(params, "d", dbID) || !map_has_key(itsCategoriesByTag["IC"][ITS_IDXMAP], dbID))
    {
        SendClientMessage(playerid, COLOR_WHITE, "z³e parametry");
        return 1;
    }
    sscanf(params, "ds[16]", dbID, strmod);

    GetPlayerPos(playerid, x, y, z);

    new textID = Its_Get(dbID, ITS_POS_3DTEXTID);
    Streamer_GetDistanceToItem(x, y, z, STREAMER_TYPE_3D_TEXT_LABEL, textID, distance);

    if(distance > 5.0)
    {
        SendClientMessage(playerid, COLOR_WHITE, "za daleko");
        return 1;
    }

    new query[1000], nick[MAX_PLAYER_NAME], rowString[2048];
    GetPlayerName(playerid, nick);
    format(query, 1000, "SELECT pc.ID FROM `mru_player_containers` pc JOIN `mru_konta` mk ON pc.PLAYERUID = mk.UID WHERE mk.Nick = '%s'", nick);
    mysql_query(query);
    mysql_store_result();
    mysql_fetch_row_format(rowString, "|");
    sscanf(rowString, "d", playerContID);
    mysql_free_result();
    ppContID = playerContID;

    if(!Its_Get(dbID, ITS_IC_ISCONTAINER))
    {
        Its_Move_Item_To_Container(dbID, playerContID);
        SendClientMessage(playerid, COLOR_WHITE, "przedmiot zostal dodany do twojego ekwipunku!");
    }
    else
    {
        itsChosenContainerID[playerid] = dbID;
        Its_ShowPickupContVariantDialog(playerid, dbID);
    }

    return 1;
}