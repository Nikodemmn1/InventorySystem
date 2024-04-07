Its_Load_Row_IC(const rowString[])
{
    new inputArray[e_ITS_ITEM_OR_CONTAINER] = {0, ...};
    sscanf(rowString, "p<|>e<dd>", inputArray);

    if(!Bit_Get(itsClassesICUsed, inputArray[ITS_IC_CLASSID]))
    {
        printf("Its_Load_Row_IC() - klasa o ID %d odczytanym z bazy danych SQL nie istnieje, badz nie zostala poprawnie wczytana!", inputArray[ITS_IC_CLASSID]);
        return 0;
    }

    new dbID = inputArray[ITS_IC_DBID];
    if(!map_has_key(itsCategoriesByTag["BI"][ITS_IDXMAP], dbID))
    {
        inputArray[ITS_IC_ISCONTAINER] = true;
        Its_Push_BC(dbID, list_new(), 0);
    }

    //TODO: USUN
    //printf("inputArrayIC:"); //a
    //printf("%d %d %d", dbID, inputArray[ITS_IC_CLASSID], inputArray[ITS_IC_ISCONTAINER]); //a

    return Its_Push(dbID, inputArray, itsCategoriesByTag["IC"]);
}

Its_Load_Row_BI(const rowString[])
{
    new inputArray[e_ITS_BASIC_ITEM];
    inputArray[ITS_BI_PARENTCONTAINER] = ITS_NULL;
    sscanf(rowString, "p<|>'"#ITS_ITEMS_DELIMITER_S"'E<dl>(-1,0)D(-1)", inputArray, inputArray[ITS_BI_PARENTCONTAINER]);

    //TODO: USUN
    //printf("inputArrayI:"); //a
    //printf("%d %d %d", inputArray[ITS_BI_ITEM_DBID], inputArray[ITS_BI_ISPERMAMENT], inputArray[ITS_BI_PARENTCONTAINER]); //a

    if(inputArray[ITS_BI_ITEM_DBID] != ITS_NULL)
    {
        if(!Its_Push(inputArray[ITS_BI_ITEM_DBID], inputArray, itsCategoriesByTag["BI"]))
        {
            return 0;
        }
    }

    return 1;
}

Its_Load_Row_POS(const rowString[])
{
    new inputArray[e_ITS_IC_POS];
    inputArray[ITS_POS_OWNERID] = ITS_NULL;
    inputArray[ITS_POS_OBJECTID] = ITS_NULL;
    inputArray[ITS_POS_3DTEXTID] = ITS_NULL;
    sscanf(rowString, "p<|>'"#ITS_IC_POS_DELIMITER_S"'E<dfffdd>(-1,-1.0,-1.0,-1.0,-1,-1)D(-1)", inputArray, inputArray[ITS_POS_OWNERID]);

    //TODO: USUN
    //printf("inputArrayP:"); //a
    //printf("%d %f %f %f %d %d %d", inputArray[ITS_POS_DBID], inputArray[ITS_POS_X], inputArray[ITS_POS_Y], inputArray[ITS_POS_Z], inputArray[ITS_POS_INTERIOR], inputArray[ITS_POS_VW], inputArray[ITS_POS_OWNERID]); //a

    if(inputArray[ITS_POS_DBID] != ITS_NULL)
    {
        Its_Push(inputArray[ITS_POS_DBID], inputArray, itsCategoriesByTag["POS"]);
        Its_Place_Item_Object(inputArray[ITS_POS_DBID], inputArray[ITS_POS_X], inputArray[ITS_POS_Y], inputArray[ITS_POS_Z], inputArray[ITS_POS_INTERIOR], inputArray[ITS_POS_VW]);
    }

    return 1;
}

Its_Load_Row_PC(const rowString[])
{
    new inputArray[e_ITS_PLAYER_CONTAINER];
    sscanf(rowString, "p<|>'"#ITS_PC_DELIMITER_S"'E<dd>(-1,-1)", inputArray);

    //TODO: USUN
    printf("inputArrayPC:"); //a
    printf("%d %d", inputArray[ITS_PC_DBID], inputArray[ITS_PC_UID]); //a

    if(inputArray[ITS_PC_DBID] != ITS_NULL)
    {
        map_add(UIDToContID, inputArray[ITS_PC_UID], inputArray[ITS_PC_DBID]); //TODO: USUN
        return Its_Push(inputArray[ITS_PC_DBID], inputArray, itsCategoriesByTag["PC"]);
    }

    return 1;
}

Its_Load_Row_SPMOD(const rowString[])
{
    new inputArray[e_ITS_SPECIAL_MODEL];
    sscanf(rowString, "p<|>'"#ITS_SPMOD_DELIMITER_S"'E<dd>(-1,-1)", inputArray);

    //TODO: USUN
    //printf("inputArraySPMOD:"); //a
    //printf("%d %d", inputArray[ITS_SPMOD_DBID], inputArray[ITS_SPMOD_MODELID]); //a

    if(inputArray[ITS_SPMOD_DBID] != ITS_NULL)
    {
        return Its_Push(inputArray[ITS_SPMOD_DBID], inputArray, itsCategoriesByTag["SPMOD"]);
    }

    return 1;
}

Its_Load_Row_ATP(const rowString[])
{
    new inputArray[e_ITS_ITEM_ATTACHMENT];
    sscanf(rowString, "p<|>'"#ITS_ATP_DELIMITER_S"'E<ddfffffffffdd>(-1,-1,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1,-1)", inputArray);

    //TODO: USUN
    //printf("inputArrayATP:"); //a
    //printf("%d", inputArray[ITS_ATP_DBID]); //a

    if(inputArray[ITS_ATP_DBID] != ITS_NULL)
    {
        return Its_Push(inputArray[ITS_ATP_DBID], inputArray, itsCategoriesByTag["ATP"]);
        // TODO: UMIEŒÆ TUTAJ JAKOŒ PRZEDMIOT? DODAJ DO LISTY ATTACHEMENTÓW W PLAYERINFO?
    }

    return 1;
}

Its_Load_Put_In_Containers(List:idsList)
{
    for(new i = 0; i < list_size(idsList); i++)
    {
        new dbID = list_get(idsList, i);
        new parentContainer = Its_Get(dbID, ITS_BI_PARENTCONTAINER);

        if(itsNotExist)
        {
            continue;
        }

        if(parentContainer != ITS_NULL)
        {
            __Its_Append_To_Container(dbID, parentContainer);
        }
    }

    return 1;
}

Its_Load_Non_Recursive(query[], &List:loadedIDs = List:ITS_NULL)
{
    new rowString[2048], dbID;
    new List:idsList = list_new();

    if(!mysql_query(query))
    {
        printf("Blad MySql w Its_Load_Non_Recursive(): errno %d!", mysql_errno());
        printf(query);
        SendRconCommand("exit");
        return 0;
    }

    mysql_store_result();
    while(mysql_fetch_row_format(rowString, "|"))
    {
        //TODO: USUN
        // /printf(rowString);

        sscanf(rowString, "p<|>d", dbID);
        list_add(idsList, dbID);

        //printf("===============> loading dbID: %d <===============", dbID); //a

        Its_Load_Row_BI(rowString);
        Its_Load_Row_IC(rowString);
        Its_Load_Row_SPMOD(rowString);
        Its_Load_Row_POS(rowString);
        Its_Load_Row_PC(rowString);
        Its_Load_Row_ATP(rowString);

        //printf("___________________________________________________", dbID); //a
    }
    mysql_free_result();

    Its_Load_Put_In_Containers(idsList);

    if(loadedIDs != List:ITS_NULL)
    {
        loadedIDs = idsList;
    }
    else
    {
        list_delete(idsList);
    }

    return 1;
}

Its_Load_Recursive(query[], &List:loadedIDs = List:ITS_NULL)
{
    new List:idsList;

    Its_Load_Non_Recursive(query, idsList);

    new recursiveQuery[RSELECT_QUERY_SIZE], whereQ[RSELECT_SINGLE_SIZE];
    new listIdx = 0;

    while(listIdx < list_size(idsList))
    {
        new thisBatchSize = 0, anyToLoad = false;
        format(recursiveQuery, sizeof(recursiveQuery), "%s WHERE i.CONTAINERID IN (", ITS_SELECT_QUERY_BASE);

        for(; thisBatchSize < RSELECT_BULK_SIZE && listIdx < list_size(idsList); listIdx++, thisBatchSize++)
        {
            new newID = list_get(idsList, listIdx);
            if(Its_Get(newID, ITS_IC_ISCONTAINER))
            {
                format(whereQ, RSELECT_SINGLE_SIZE, "%d,", newID);
                strcat(recursiveQuery, whereQ);
                anyToLoad = true;
            }
        } 

        if(anyToLoad)
        {
            recursiveQuery[strlen(recursiveQuery) - 1] = ')'; // Domkniêcie wartoœci po IN - znak ')' zamiast przecinka
            Its_Load_Non_Recursive(recursiveQuery);
        }
    }

    if(loadedIDs != ITS_NULL)
    {
        loadedIDs = idsList;
    }
    else
    {
        list_delete(idsList);
    }

    return 1;
}

Its_Load(query[], recursive, &List:loadedIDs = List:ITS_NULL)
{
    if(recursive)
    {
        return Its_Load_Recursive(query, loadedIDs);
    }
    else
    {
        return Its_Load_Non_Recursive(query, loadedIDs);
    }
}
