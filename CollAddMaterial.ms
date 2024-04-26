/*
 - CollAddMaterials 1.0
  for 3ds Max 2009+

  https://github.com/egasvegas1109/CollAddMaterial
  Author: EgasVegas
  vk.com/egasvegas
  t.me/egasvegas
*/
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
                    
                    -- Создаем временный массив для хранения индексов текстур, которые нужно заменить
                    
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


fn weldAndSmoothGroup obj = (
    obj.weldThreshold=0.001
    polyOp.weldVertsByThreshold obj #{1..obj.numVerts}

    -- Применение автоматического сглаживания
    smoothMod = Smooth()
    smoothMod.autoSmooth = true
    addModifier obj smoothMod
    convertToPoly obj
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
    combobox cb_1  pos:[5, 70] items:#("Grass_128HV", "Grass_128HV2", "", "") width:150 height:3

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
        if (mt_2_cb.checked == false) then (
            matBtn_2.enabled = false
            cb_2.enabled = false
        )
        if (mt_3_cb.checked == false) then (
            matBtn_3.enabled = false
            cb_3.enabled = false
        )
        if (mt_4_cb.checked == false) then (
            matBtn_4.enabled = false
            cb_4.enabled = false
        )
     )
    -----------------------ОБРАБОТЧИКИ ЧЕКБОКСОВ-----------------------
     on mt_1_cb changed theState do (
        matBtn_1.enabled = theState
        cb_1.enabled = theState
     )

     on mt_2_cb changed theState do (
        matBtn_2.enabled = theState
        cb_2.enabled = theState
     )

     on mt_3_cb changed theState do (
        matBtn_3.enabled = theState
        cb_3.enabled = theState
     )

     on mt_4_cb changed theState do (
        matBtn_4.enabled = theState
        cb_4.enabled = theState
     )
    -----------------------ОБРАБОТЧИКИ СПИСКОВ-----------------------
    on cb_1 entered txt do (
        cb_1.selected = txt
    )

    on cb_2 entered txt do (
        cb_2.selected = txt
    )

    on cb_3 entered txt do (
        cb_3.selected = txt
    )

    on cb_4 entered txt do (
        cb_4.selected = txt
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

			label lbl1 "CollAddMaterial 1.0"  height:17
			label lbl6 "Script features:" pos:[11,33] 
			label lbl7 "- Mass overlay of materials" pos:[13,53] 
			label lbl9 "- Choosing the quantity of materials" pos:[13,73] 
			label lbl10 "- Support for multi-materials and single" pos:[13,93] 
			label lbl11 "_____________________________"
			label lbl2 "\xa9 by " pos:[10,133] width:42 height:18
			HyperLink Goldfish "EgasVegas" pos:[37,133] width:60 height:18 address:"https://t.me/egasvegas" color:(color 10 147 225) hovercolor:(color 94 198 255) visitedcolor:(color 10 147 225)
            button btn_close "close" pos:[215,133] width:69 height:22
            on btn_close pressed do DestroyDialog  rol_meChecker_about 
		)
        createDialog rol_meChecker_about modal:true 
    )

    on btnApply pressed do (
        materials_prog.value = 0
        
        local materialArray = #()
        local textureArray = #()

        local textureArray_1 = #() -- Создаем массив для хранения списков текстур для материала 1

        local textureArray_2 = #() -- Создаем массив для хранения списков текстур для материала 2

        local textureArray_3 = #() -- Создаем массив для хранения списков текстур для материала 3

        local textureArray_4 = #() -- Создаем массив для хранения списков текстур для материала 4
    
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