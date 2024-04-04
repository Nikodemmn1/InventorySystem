Its_Load_Item_Categories()
{
    mysql_query("SELECT * FROM `mru_item_and_container_categories`");
    mysql_store_result();
    
    new query[256 + ITS_SQL_TABLE_MAX_LEN], rowString[256], columnName[ITS_SQL_COLUMN_MAX_LEN];
    new categoryID, maxCategoryID = -1;
    new categoryTmp[e_ITS_CATEGORY];
    while(mysql_fetch_row_format(rowString, "|"))
    {
        sscanf(rowString, "p<|>de<s["#ITS_CAT_TAG_SIZE"]s["#ITS_CAT_FRIENDLYNAME_SIZE"]s["#ITS_SQL_TABLE_MAX_LEN"]s["#ITS_SQL_TABLE_MAX_LEN"]>",
            categoryID,
            categoryTmp
        );

        if(categoryID >= ITS_CATEGORIES_LIMIT)
        {
            printf("Za duzo klas przedmiotow i kontenerow (categoryID = %d) - zwieksz ITEM_CATEGORIES_LIMIT w kodzie!", categoryID);
		    SendRconCommand("exit");
		    return 1;
        }

        new elementSize = map_str_get(itsElemSizeByTag, categoryTmp[ITS_CAT_TAG]);

        categoryTmp[ITS_ARR] = MEM_UM_new_zero(ITS_IC_INITIAL_LIMIT * elementSize);
        categoryTmp[ITS_SIZE] = ITS_IC_INITIAL_LIMIT;
        categoryTmp[ITS_COUNT] = 0;
        categoryTmp[ITS_IDXMAP] = map_new();
        categoryTmp[ITS_HOLES] = list_new();
        categoryTmp[ITS_ELEM_SIZE] = elementSize;
        map_str_get_arr(itsFunctionsByTag, categoryTmp[ITS_CAT_TAG], categoryTmp[ITS_FUNCTIONS]);
        categoryTmp[ITS_SQL_COLUMNS] = list_new();
        categoryTmp[ITS_UPDATE_DIRTY] = map_new();
        categoryTmp[ITS_TO_DELETE] = list_new();

        if(map_has_str_key(itsClassArrAmxAddrByTag, categoryTmp[ITS_CAT_TAG]))
        {
            categoryTmp[ITS_CLASSES_ARRAY_AMX_ADDR] = map_str_get(itsClassArrAmxAddrByTag,  categoryTmp[ITS_CAT_TAG]);
        }
        else
        {
            categoryTmp[ITS_CLASSES_ARRAY_AMX_ADDR] = ITS_NULL;
        }

        if(map_has_str_key(itsClassElemSizeByTag, categoryTmp[ITS_CAT_TAG]))
        {
            categoryTmp[ITS_CLASS_ELEM_SIZE] = map_str_get(itsClassElemSizeByTag, categoryTmp[ITS_CAT_TAG]);
        }
        else
        {
            categoryTmp[ITS_CLASS_ELEM_SIZE] = ITS_NULL;
        }

        categoryTmp[ITS_TO_INSERT_ADDITIONAL] = list_new();

        map_str_add(itsCategoryIDByTag, categoryTmp[ITS_CAT_TAG], categoryID);
        list_add_str(itsCategoriesHierarchy, categoryTmp[ITS_CAT_TAG]);

        WritePhysMemory(_:MEM_UM_get_addr(itsCategories[categoryID][e_ITS_CATEGORY:0]), categoryTmp, _:e_ITS_CATEGORY);
        Bit_Let(itsCategoriesUsed, categoryID);

        if(categoryID > maxCategoryID)
        {
            maxCategoryID = categoryID;
        }
    }

    mysql_free_result();

    for(categoryID = 0; categoryID < maxCategoryID; categoryID++)
    {
        if(!Bit_Get(itsCategoriesUsed, categoryID))
        {
            continue;
        }

        if(strcmp(itsCategories[categoryID][ITS_CAT_TABLENAME], "NULL") == 0)
        {
            continue;
        }

        format(query, sizeof(query), "SELECT COLUMN_NAME FROM `INFORMATION_SCHEMA`.`COLUMNS` WHERE TABLE_NAME = '%s'", itsCategories[categoryID][ITS_CAT_TABLENAME]);
        mysql_query(query);
        mysql_store_result();

        while(mysql_fetch_row_format(rowString, "|"))
        {
            sscanf(rowString, "s["#ITS_SQL_COLUMN_MAX_LEN"]", columnName);

            if(strcmp(columnName, "ID") == 0)
            {
                continue;
            }

            list_add_str(itsCategories[categoryID][ITS_SQL_COLUMNS], columnName);
        }

        mysql_free_result();
    }

    return 1;
}
