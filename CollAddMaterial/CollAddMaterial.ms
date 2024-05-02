/*
 - CollAddMaterials 1.1
  for 3ds Max 2009+

  https://github.com/egasvegas1109/CollAddMaterial
  Author: EgasVegas
  vk.com/egasvegas
  t.me/egasvegas
*/

fn weldAndSmoothGroup obj = (
    obj.weldThreshold=0.001
    polyOp.weldVertsByThreshold obj #{1..obj.numVerts}

    -- Применение автоматического сглаживания
    smoothMod = Smooth()
    smoothMod.autoSmooth = true
    addModifier obj smoothMod
    convertToPoly obj
)

fn applyMaterialToPolygonsWithTexture textureName newMaterial models_prog prgrs_models = 
(
    models_prog.value = 0
    for obj in selection do 
    (
        prgrs_models.text = obj.name
        convertToPoly obj
        weldAndSmoothGroup obj
        -- print (format "Материалов %\n" newMaterial.count)
        -- print (format "Текстур %\n" textureName.count)        

        if classof obj.material == MultiMaterial then 
        (
            -- Работаем с мультиматериалом
            local multiMat = obj.material 
                for i = 1 to multiMat.numsubs do 
                (
                    local subMat = multiMat[i]
                    for j = 1 to textureName.count do 
                    (
                        if isProperty subMat #diffuseMap then 
                        (
                            -- print(format "Текстура на модели %\n" (toLower(getFilenameFile(subMat.diffuseMap.fileName))))
                            -- print(format "Текстура ожидаемая %\n" (toLower(textureName[j])))
                            if classof subMat.diffuseMap == BitmapTex and toLower(getFilenameFile(subMat.diffuseMap.fileName)) == toLower(textureName[j]) then 
                            (
                                multiMat[i] = newMaterial -- Заменяем суб-материал
                            )
                        )
                    )
                )
        ) else (
            -- Работаем с одиночным материалом
            local mat = obj.material
            for j = 1 to textureName.count do 
            (
                if isProperty mat #diffuseMap then 
                (
                    if classof mat.diffuseMap == BitmapTex and toLower(getFilenameFile(mat.diffuseMap.fileName)) == toLower(textureName[j]) then (
                        obj.material = newMaterial
                    )
                )
            )
        )
        models_prog.value += 100/selection.count + 1
    )
)


fn addTexturesToArray checkBox comboBox textureArray = (
    if checkBox.checked do (
        for i = 1 to comboBox.items.count do (
            if (comboBox.items[i] != "") do(
                append textureArray comboBox.items[i]
            )
        )
    )
)

fn addArrayToArray array arrayChild = (
    if (arrayChild.count > 0) do (
        append array arrayChild
    )
)

fn SetINI key value_= (
	try (
		if  key == "material_1" then (
			if value_ == true then (setINISetting (scriptsPath + "CollAddMaterial\settings.ini") "MaterialStatus" "material_1" "1" )
			else if value_ == false then (setINISetting (scriptsPath + "CollAddMaterial\settings.ini") "MaterialStatus" "material_1" "0" )
		)
        if  key == "material_2" then (
			if value_ == true then (setINISetting (scriptsPath + "CollAddMaterial\settings.ini") "MaterialStatus" "material_2" "1" )
			else if value_ == false then (setINISetting (scriptsPath + "CollAddMaterial\settings.ini") "MaterialStatus" "material_2" "0" )
		)
        if  key == "material_3" then (
			if value_ == true then (setINISetting (scriptsPath + "CollAddMaterial\settings.ini") "MaterialStatus" "material_3" "1" )
			else if value_ == false then (setINISetting (scriptsPath + "CollAddMaterial\settings.ini") "MaterialStatus" "material_3" "0" )
		)
        if  key == "material_4" then (
			if value_ == true then (setINISetting (scriptsPath + "CollAddMaterial\settings.ini") "MaterialStatus" "material_4" "1" )
			else if value_ == false then (setINISetting (scriptsPath + "CollAddMaterial\settings.ini") "MaterialStatus" "material_4" "0" )
		)
	) catch (format "error autoSet % %\n" key value_)
)

fn SetINITextures textureArray1 textureArray2 textureArray3 textureArray4 = (
    local iniFilePath = (getDir #scripts + "\\CollAddMaterial\\settings.ini") -- Путь к файлу .ini
    
    try (
        -- Сохраняем текстуры для combobox'а 1
        for i = 1 to textureArray1.count do (
            setINISetting iniFilePath "TexturesName" ("cb1_" + (i as string)) textureArray1[i]
        )
        
        -- Сохраняем текстуры для combobox'а 2
        for i = 1 to textureArray2.count do (
            setINISetting iniFilePath "TexturesName" ("cb2_" + (i as string)) textureArray2[i]
        )
        
        -- Сохраняем текстуры для combobox'а 3
        for i = 1 to textureArray3.count do (
            setINISetting iniFilePath "TexturesName" ("cb3_" + (i as string)) textureArray3[i]
        )
        
        -- Сохраняем текстуры для combobox'а 4
        for i = 1 to textureArray4.count do (
            setINISetting iniFilePath "TexturesName" ("cb4_" + (i as string)) textureArray4[i]
        )
    ) catch (
        format "error autoSet textures\n"
    )
)


-- Создание интерфейса
rollout textureMaterialApplicator "CollAddMaterial"(
    -- About
    button btn_about "About" width:92 height:23	 align:#right
    -----------------------ГРУППА 1-----------------------
    -- Группа материала
    groupBox grB_1 "Material 1" pos:[0, 30] width:160 height:100
    -- Чекбокс
    checkbox mt_1_cb checked:true pos:[60, 30]
    -- Элемент для перетаскивания материала
    MaterialButton matBtn_1 "Select material" pos:[5, 50] width:150 height:20 filter:material
    -- Поле для ввода имени текстуры
    combobox cb_1  pos:[5, 70] items:#("", "", "", "") width:150 height:3

    -----------------------ГРУППА 2-----------------------
    -- Группа материала
    groupBox grB_2 "Material 2" pos:[180, 30] width:160 height:100
    -- Чекбокс
    checkbox mt_2_cb checked:false pos:[240, 30]
    -- Элемент для перетаскивания материала
    MaterialButton matBtn_2 "Select material" pos:[185, 50] width:150 height:20 filter:material
    -- Поле для ввода имени текстуры
    combobox cb_2  pos:[185, 70] items:#("", "", "", "") width:150 height:3

        -----------------------ГРУППА 3-----------------------
    -- Группа материала
    groupBox grB_3 "Material 3" pos:[0, 140] width:160 height:100
    -- Чекбокс
    checkbox mt_3_cb checked:false pos:[60, 140]
    -- Элемент для перетаскивания материала
    MaterialButton matBtn_3 "Select material" pos:[5, 160] width:150 height:20 filter:material
    -- Поле для ввода имени текстуры
    combobox cb_3  pos:[5, 180] items:#("", "", "", "") width:150 height:3

    -----------------------ГРУППА 4-----------------------
    -- Группа материала
    groupBox grB_4 "Material 4" pos:[180, 140] width:160 height:100
    -- Чекбокс
    checkbox mt_4_cb checked:false pos:[240, 140]
    -- Элемент для перетаскивания материала
    MaterialButton matBtn_4 "Select material" pos:[185, 160] width:150 height:20 filter:material
    -- Поле для ввода имени текстуры
    combobox cb_4  pos:[185, 180] items:#("", "", "", "") width:150 height:3
    ------------------------------------------------------
    label prgrs_mat ""
    progressbar materials_prog color:green -- Для материалов
    label prgrs_models ""
    progressbar models_prog color:green -- Для моделей
    -- Кнопка применения материала
    button btnApply "Apply material"  width:150 align:#center
    ------------------------------------------------------
    on textureMaterialApplicator open do (
        -- Получение состояний из файла настроек
        local material_1_status = getINISetting (scriptsPath + "CollAddMaterial\settings.ini") "MaterialStatus" "material_1"
        local material_2_status = getINISetting (scriptsPath + "CollAddMaterial\settings.ini") "MaterialStatus" "material_2"
        local material_3_status = getINISetting (scriptsPath + "CollAddMaterial\settings.ini") "MaterialStatus" "material_3"
        local material_4_status = getINISetting (scriptsPath + "CollAddMaterial\settings.ini") "MaterialStatus" "material_4"
    
        -- Установка состояний чекбоксов и активации/деактивации элементов интерфейса
        if ((material_1_status as integer) == 1) then (
            mt_1_cb.checked = true
            matBtn_1.enabled = true
            cb_1.enabled = true
        ) else (
            mt_1_cb.checked = false
            matBtn_1.enabled = false
            cb_1.enabled = false
        )
    
        if ((material_2_status as integer) == 1) then (
            mt_2_cb.checked = true
            matBtn_2.enabled = true
            cb_2.enabled = true
        ) else (
            mt_2_cb.checked = false
            matBtn_2.enabled = false
            cb_2.enabled = false
        )
    
        if ((material_3_status as integer) == 1) then (
            mt_3_cb.checked = true
            matBtn_3.enabled = true
            cb_3.enabled = true
        ) else (
            mt_3_cb.checked = false
            matBtn_3.enabled = false
            cb_3.enabled = false
        )
    
        if ((material_4_status as integer) == 1) then (
            mt_4_cb.checked = true
            matBtn_4.enabled = true
            cb_4.enabled = true
        ) else (
            mt_4_cb.checked = false
            matBtn_4.enabled = false
            cb_4.enabled = false
        )
        

        -- Получение названий текстур из файла настроек и загрузка их в combobox'ы
        local iniFilePath = (getDir #scripts + "\\CollAddMaterial\\settings.ini") -- Путь к файлу .ini
        
        local textureList_cb1 = #()
        for i = 1 to 4 do (
            local textureName = getINISetting iniFilePath "TexturesName" ("cb1_" + i as string)
            if textureName != undefined do (
                append textureList_cb1 textureName
            )
        )
        cb_1.items = textureList_cb1

        local textureList_cb2 = #()
        for i = 1 to 4 do (
            local textureName = getINISetting iniFilePath "TexturesName" ("cb2_" + i as string)
            if textureName != undefined do (
                append textureList_cb2 textureName
            )
        )
        cb_2.items = textureList_cb2

        local textureList_cb3 = #()
        for i = 1 to 4 do (
            local textureName = getINISetting iniFilePath "TexturesName" ("cb3_" + i as string)
            if textureName != undefined do (
                append textureList_cb3 textureName
            )
        )
        cb_3.items = textureList_cb3

        local textureList_cb4 = #()
        for i = 1 to 4 do (
            local textureName = getINISetting iniFilePath "TexturesName" ("cb4_" + i as string)
            if textureName != undefined do (
                append textureList_cb4 textureName
            )
        )
        cb_4.items = textureList_cb4

    )
    
    -----------------------ОБРАБОТЧИКИ ЧЕКБОКСОВ-----------------------
     on mt_1_cb changed theState do (
        SetINI "material_1" theState
        matBtn_1.enabled = theState
        cb_1.enabled = theState
     )

     on mt_2_cb changed theState do (
        SetINI "material_2" theState
        matBtn_2.enabled = theState
        cb_2.enabled = theState
     )

     on mt_3_cb changed theState do (
        SetINI "material_3" theState
        matBtn_3.enabled = theState
        cb_3.enabled = theState
     )

     on mt_4_cb changed theState do (
        SetINI "material_4" theState
        matBtn_4.enabled = theState
        cb_4.enabled = theState
     )
    -----------------------ОБРАБОТЧИКИ СПИСКОВ-----------------------
    on cb_1 entered txt do (
        cb_1.selected = txt
        -- Вызываем функцию SetINITextures с массивами текстур для каждого combobox'а
        local textureArray1 = #(cb_1.items[1], cb_1.items[2], cb_1.items[3], cb_1.items[4])
        SetINITextures textureArray1 #() #() #()
    )
    
    on cb_2 entered txt do (
        cb_2.selected = txt
        -- Вызываем функцию SetINITextures с массивами текстур для каждого combobox'а
        local textureArray2 = #(cb_2.items[1], cb_2.items[2], cb_2.items[3], cb_2.items[4])
        SetINITextures #() textureArray2 #() #()
    )
    
    on cb_3 entered txt do (
        cb_3.selected = txt
        -- Вызываем функцию SetINITextures с массивами текстур для каждого combobox'а
        local textureArray3 = #(cb_3.items[1], cb_3.items[2], cb_3.items[3], cb_3.items[4])
        SetINITextures #() #() textureArray3 #()
    )
    
    on cb_4 entered txt do (
        cb_4.selected = txt
        -- Вызываем функцию SetINITextures с массивами текстур для каждого combobox'а
        local textureArray4 = #(cb_4.items[1], cb_4.items[2], cb_4.items[3], cb_4.items[4])
        SetINITextures #() #() #() textureArray4
    )
    
    
    -----------------------ОБРАБОТЧИКИ ВЫБОРА МАТЕРИАЛОВ-----------------------
    on matBtn_1 picked m do (
        if classof m == GTA_COLSurface then (
            matBtn_1.material = m
            matBtn_1.caption = m.name
        ) else (
            messageBox "Wrong format."
        )
    )

    on matBtn_2 picked m do (
        if classof m == GTA_COLSurface then (
            matBtn_2.material = m
            matBtn_2.caption = m.name
        ) else (
            messageBox "Wrong format."
        )
    )

    on matBtn_3 picked m do (
        if classof m == GTA_COLSurface then (
            matBtn_3.material = m
            matBtn_3.caption = m.name
        ) else (
            messageBox "Wrong format."
        )
    )

    on matBtn_4 picked m do (
        if classof m == GTA_COLSurface then (
            matBtn_4.material = m
            matBtn_4.caption = m.name
        ) else (
            messageBox "Wrong format."
        )
    )
    -----------------------ОБРАБОТЧИКИ КНОПОК-----------------------
    on btn_about pressed do (
        rollout rol_meChecker_about "CollAddMaterial - About" width:295   (

			label lbl1 "CollAddMaterial 1.1"  height:17
			label lbl6 "Script features:" pos:[11,33] 
			label lbl7 "- Mass overlay of materials" pos:[13,53] 
			label lbl9 "- Choosing the quantity of materials" pos:[13,73] 
			label lbl10 "- Support for multi-materials and single" pos:[13,93]
            label lbl11 "- Saving settings" pos:[13,113] 
			label lbl12 "_____________________________"
			label lbl2 "\xa9 by " pos:[10,153] width:42 height:18
			HyperLink Goldfish "EgasVegas" pos:[37,153] width:60 height:18 address:"https://t.me/egasvegas" color:(color 10 147 225) hovercolor:(color 94 198 255) visitedcolor:(color 10 147 225)
            button btn_close "close" pos:[215,153] width:69 height:22
            on btn_close pressed do DestroyDialog  rol_meChecker_about 
		)
        createDialog rol_meChecker_about modal:true 
    )

    on btnApply pressed do (
        materials_prog.value = 0
        
        local materialArray = #()
        local textureArray = #()

    -- Создаем массивы для хранения списков текстур
        local textureArray_1 = #()
        local textureArray_2 = #()
        local textureArray_3 = #()
        local textureArray_4 = #()
    
        -- Проверяем состояние чекбокса и добавляем соответствующие материалы и текстуры в массивы
        if mt_1_cb.checked and matBtn_1.material != undefined do (
            append materialArray matBtn_1.material
            addTexturesToArray mt_1_cb cb_1 textureArray_1
        )

        if mt_2_cb.checked and matBtn_2.material != undefined do (
            append materialArray matBtn_2.material
            addTexturesToArray mt_2_cb cb_2 textureArray_2
        )

        if mt_3_cb.checked and matBtn_3.material != undefined do (
            append materialArray matBtn_3.material
            addTexturesToArray mt_3_cb cb_3 textureArray_3
        )

        if mt_4_cb.checked and matBtn_4.material != undefined do (
            append materialArray matBtn_4.material
            addTexturesToArray mt_4_cb cb_4 textureArray_4
        )
        
        --Создание многомерного массива текстур
        addArrayToArray textureArray textureArray_1
        addArrayToArray textureArray textureArray_2
        addArrayToArray textureArray textureArray_3
        addArrayToArray textureArray textureArray_4

        -- Проверяем, что было выбрано хотя бы одно сочетание материала и текстуры
        if materialArray.count > 0 and textureArray.count > 0 then (
            -- Вызываем функцию и передаем ей массивы материалов и текстур
            -- print (materialArray.count)
            -- print (textureArray.count)

            for i = 1 to materialArray.count do (
                prgrs_mat.text = materialArray[i] as string
                applyMaterialToPolygonsWithTexture textureArray[i] materialArray[i] models_prog prgrs_models
                materials_prog.value += 100/materialArray.count + 1
            )

            messageBox "Done!"
        ) else (
            messageBox "Please specify both a material and a texture name."
        )
    )
    
)
-- Отображение интерфейса
createdialog textureMaterialApplicator 340 350