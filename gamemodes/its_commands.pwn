YCMD:register(playerid, params[], help)
{
    if(isnull(params))
    {
        SendClientMessage(playerid, COLOR_WHITE, "Podaj haslo!");
        return 1;
    }

    new playerNick[MAX_PLAYER_NAME];
    new query[512];
    new msg[64];

    GetPlayerName(playerid, playerNick, sizeof(playerNick));

	format(query, sizeof(query), "SELECT `Nick` FROM `mru_konta` WHERE `Nick` = BINARY '%s'", playerNick);
	mysql_query(query);
	mysql_store_result();
	new existingAccountsCount = mysql_num_rows();
	mysql_free_result();

	if(existingAccountsCount > 0)
	{
        SendClientMessage(playerid, COLOR_WHITE, "Konto tego gracza ju¿ istnieje!");
		return 1;
	}

    format(query, sizeof(query), "INSERT INTO `mru_konta` (`Nick`, `Key`, `Salt`) VALUES ('%s', '%s', '%s')", playerNick, "daskldjasldksa", "sdlaksdjsadlks");
	mysql_query(query);
    new UID = mysql_insert_id();

    new tempDbID = Its_Create_PC(UID);

    new Map:translationMap;
    Its_MassInsert(true, translationMap);

    format(msg, sizeof(msg), "Konto %s i kontener gracza (ID %d) zosta³y utworzone.", playerNick, map_get(translationMap, tempDbID));
    SendClientMessage(playerid, COLOR_WHITE, msg);

    map_delete(translationMap);

    return 1;
}

YCMD:debugcc(playerid, params[], help) //TODO: USUN!!!!!!!!!!!
{
    printf(">> Kategorie:");
    for(new i = 0; i < ITS_CATEGORIES_LIMIT; i++)
    {
        if(Bit_Get(itsCategoriesUsed, i))
        {
            printf("[%d]:\n\tag: %s\n\tcNameFriendly: %s", i, itsCategories[i][ITS_CAT_TAG], itsCategories[i][ITS_CAT_FRIENDLYNAME]);
        }
    }

    printf(">> Klasy:");
    for(new i = 0; i < ITS_IC_CLASS_LIMIT; i++)
    {
        if(Bit_Get(itsClassesICUsed, i))
        {
            printf("[%d]:\n\tcategoryID: %d\n\ttName: %s\n\ttNameFriendly: %s\n\tisPlaceable: %d\n\tisPersistent: %d\n\tmodelID: %d\n", i,
                itsClassesIC[i][ITS_CL_IC_CATEGORY],
                itsClassesIC[i][ITS_CL_IC_NAME], 
                itsClassesIC[i][ITS_CL_IC_FRIENDLYNAME],
                itsClassesIC[i][ITS_CL_IC_ISPLACEABLE],
                itsClassesIC[i][ITS_CL_IC_ISPERSISTENT],
                itsClassesIC[i][ITS_CL_IC_MODELID]
            );

            if(Bit_Get(itsClassesBIUsed, i))
            {
                printf("\t> Item:\n\titemSize: %d",
                    itsClassesBI[i][ITS_CL_BI_ITEMSIZE]
                );
            }
            else
            {
                printf("\t> Container:\n\tcontainerSize: %d",
                    itsClassesBC[i][ITS_CL_BC_CONTAINERSIZE]
                );
            }
        }
    }

    return 1;
}

YCMD:debugpush(playerid, params[], help) //TODO: USUN!!!!!!!!!!!
{
    new dbID, Float:x, Float:y, Float:z, interior, vw, ownerID;

    if(sscanf(params, "dfffddd", dbID, x, y, z, interior, vw, ownerID))
    {
        SendClientMessage(playerid, COLOR_WHITE, "z³e parametry");
        return 1;
    }

    if(!Its_Push_POS(dbID, x, y, z, interior, vw, ownerID))
    {
        SendClientMessage(playerid, COLOR_WHITE, "BLAD!");
        return 1;
    }

    new msg[128];
    format(msg, sizeof(msg), "wrzucono [%d]: %f %f %f %d %d %d", dbID, x, y, z, interior, vw, ownerID);
    SendClientMessage(playerid, COLOR_WHITE, msg);

    return 1;
}

YCMD:debugpop(playerid, params[], help) //TODO: USUN!!!!!!!!!!!
{
    new dbID;

    if(sscanf(params, "d", dbID))
    {
        SendClientMessage(playerid, COLOR_WHITE, "z³e parametry");
        return 1;
    }

    if(!Its_Pop(dbID, map_str_get(itsCategoryIDByTag, "POS")))
    {
        SendClientMessage(playerid, COLOR_WHITE, "BLAD!");
        return 1;
    }

    SendClientMessage(playerid, COLOR_WHITE, "pobrano");

    return 1;
}

YCMD:debugprintitc(playerid, params[], help) //TODO: USUN!!!!!!!!!!!
{
    new msg[128];
    SendClientMessage(playerid, COLOR_WHITE, "==========");
    printf("==========");
    for(new i = 0; i < itsCategoriesByTag["POS"][ITS_SIZE]; i++)
    {
        new arr[e_ITS_IC_POS];
        MEM_UM_get_arr(itsCategoriesByTag["POS"][ITS_ARR], i*_:e_ITS_IC_POS, arr);
        format(msg, sizeof(msg), "[%d]: %f %f %f %d %d %d", arr[ITS_POS_DBID], arr[ITS_POS_X], arr[ITS_POS_Y], arr[ITS_POS_Z], arr[ITS_POS_INTERIOR], arr[ITS_POS_VW], arr[ITS_POS_OWNERID]);
        SendClientMessage(playerid, COLOR_WHITE, msg);
        printf("%s", msg);
    }
    printf("==========");
    SendClientMessage(playerid, COLOR_WHITE, "==========");

    return 1;
}

YCMD:debugprintcont(playerid, params[], help) //TODO: USUN!!!!!!!!!!!
{
    for(new Iter:icIter=map_iter(itsCategoriesByTag["IC"][ITS_IDXMAP]);iter_inside(icIter);iter_move_next(icIter))
    {
        new dbID = iter_get_key(icIter);
        if(!itsNotExist && Its_Get(dbID, ITS_IC_ISCONTAINER))
        {
            printf("Container %d [%d/%d]:", dbID, Its_Get(dbID, ITS_BC_TAKEN_SPACE), Its_Get(dbID, ITS_CL_BC_CONTAINERSIZE));
            new List:itemsList = List:Its_Get(dbID, ITS_BC_CONT_ITEMS);
            for(new i = 0; i < list_size(itemsList); i++)
            {
                printf("\t>%d: %d", i, list_get(itemsList, i));
            }
        }
    }

    return 1;
}

YCMD:debugcreate(playerid, params[], help) //TODO: USUN!!!!
{
    for(new i = 0; i < 5000; i++)
    {
        Its_Create_PC(2);
        Its_Create_BC(2);
        Its_Create_BI(3, false, 4);

        new dbID = Its_Create_BI(3, false, ITS_NULL);
        Its_Create_POS(dbID, 6.3, 7.4, 8.5, 0, 0, ITS_NULL);
    }

    return 1;
}

YCMD:debugins(playerid, params[], help) //TODO: USUN!!!!
{
    SendClientMessage(playerid, COLOR_WHITE, "Rozpoczynam mass insert!");
    Its_MassInsert();
    SendClientMessage(playerid, COLOR_WHITE, "MAss insert zrobiony!");
    return 1;
}

YCMD:debugprintlist4(playerid, params[], help) //TODO: USUN!!!!
{
    new List:itemIds = List:Its_Get(4, ITS_BC_CONT_ITEMS);
    for(new i = 0; i < list_size(itemIds); i++)
    {
        printf("W kontenerze 4 jest dbID %d", list_get(itemIds, i));
    }

    return 1;
}

YCMD:debugupdate(playerid, params[], help) //TODO: USUN!!!!
{
    for(new Iter:icIter=map_iter(itsCategoriesByTag["IC"][ITS_IDXMAP]);iter_inside(icIter);iter_move_next(icIter))
    {
        new dbID = iter_get_key(icIter);
        map_add(itsCategoriesByTag["IC"][ITS_UPDATE_DIRTY], dbID, true);
    }
    for(new Iter:icIter=map_iter(itsCategoriesByTag["POS"][ITS_IDXMAP]);iter_inside(icIter);iter_move_next(icIter))
    {
        new dbID = iter_get_key(icIter);
        map_add(itsCategoriesByTag["POS"][ITS_UPDATE_DIRTY], dbID, true);
    }
    for(new Iter:icIter=map_iter(itsCategoriesByTag["BI"][ITS_IDXMAP]);iter_inside(icIter);iter_move_next(icIter))
    {
        new dbID = iter_get_key(icIter);
        map_add(itsCategoriesByTag["BI"][ITS_UPDATE_DIRTY], dbID, true);
    }
    for(new Iter:icIter=map_iter(itsCategoriesByTag["PC"][ITS_IDXMAP]);iter_inside(icIter);iter_move_next(icIter))
    {
        new dbID = iter_get_key(icIter);
        map_add(itsCategoriesByTag["PC"][ITS_UPDATE_DIRTY], dbID, true);
    }
    Its_Set(5, ITS_IC_CLASSID, 4);

    SendClientMessage(playerid, COLOR_WHITE, "Rozpoczynam mass UPDATE!");
    Its_MassUpdate();
    SendClientMessage(playerid, COLOR_WHITE, "MAss UPDATE zrobiony!");
    return 1;
}

YCMD:debugdelete(playerid, params[], help) //TODO: USUN!!!
{
    Its_Delete_PC(4);
    Its_Delete_IC(142021);
    SendClientMessage(playerid, COLOR_WHITE, "Rozpoczynam mass DELETE!");
    Its_MassDeleteMysql();
    SendClientMessage(playerid, COLOR_WHITE, "MAss DELETE zrobiony!");
    return 1;
}

YCMD:debugplace(playerid, params[], help)
{
    new dbID;
    new Float:x, Float:y, Float:z;
    if(sscanf(params, "d", dbID))
    {
        SendClientMessage(playerid, COLOR_WHITE, "z³e parametry");
        return 1;
    }

    GetPlayerPos(playerid, x, y, z);
    x += 5.0; y += 5.0;
    Its_Place_Item(dbID, x, y, z, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));

    SendClientMessage(playerid, COLOR_WHITE, "polozono przedmiot");

    return 1;
}




