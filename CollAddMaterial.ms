fn applyMaterialToPolygonsWithTexture textureName newMaterial = 
(
    for obj in selection do 
    (
        convertToPoly obj
        weldAndSmoothGroup obj
        print (format "Материалов %\n" newMaterial.count)
        print (format "Текстур %\n" textureName.count)        

        if classof obj.material == MultiMaterial then 
        (
            -- Работаем с мультиматериалом
            local multiMat = obj.material
            for k = 1 to newMaterial.count do 
            (
                print (k)    
                for i = 1 to multiMat.numsubs do 
                (
                    local subMat = multiMat[i]
                    
                    -- Создаем временный массив для хранения индексов текстур, которые нужно заменить
                    local texturesToReplace = #()
                    
                    for j = 1 to textureName.count do 
                    (
                        if isProperty subMat #diffuseMap then 
                        (
                            print(format "Текстура на модели %\n" (toLower(getFilenameFile(subMat.diffuseMap.fileName))))
                            print(format "Текстура ожидаемая %\n" (toLower(textureName[j])))
                            if classof subMat.diffuseMap == BitmapTex and  toLower(getFilenameFile(subMat.diffuseMap.fileName))== toLower(textureName[j]) then 
                            (
                                -- Добавляем индекс текстуры в массив для замены
                                append texturesToReplace i
                            )
                        )
                        else (
                            print ("diffuseMap = null")
                        )
                    )
                    
                    -- Заменяем текстуры только после завершения внутреннего цикла
                    for idx in texturesToReplace do 
                    (
                        print("ZAMENILI")
                        multiMat[idx] = newMaterial[k] -- Заменяем суб-материал
                    )
                )
            )
        ) else (
            -- Работаем с одиночным материалом
            local mat = obj.material
            
            -- Создаем временный массив для хранения индексов текстур, которые нужно заменить
            local texturesToReplace = #()
            
            for j = 1 to textureName.count do (
                if classof mat.diffuseMap == BitmapTex and mat.diffuseMap.fileName == textureName[j] then (
                    -- Добавляем индекс текстуры в массив для замены
                    append texturesToReplace j
                )
            )
            
            -- Заменяем текстуры только после завершения внутреннего цикла
            for idx in texturesToReplace do 
            (
                obj.material = newMaterial[idx] -- Заменяем материал объекта
            )
        )
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
            append textureArray comboBox.items[i]
        )
    )
)

fn addArrayToArray array arrayChild = (
    if (arrayChild.count > 0) do (
        append array arrayChild
    )
)

-- Создание интерфейса
rollout textureMaterialApplicator "Texture material applicator"(
    
    -----------------------ГРУППА 1-----------------------
    -- Группа материала
    groupBox grB_1 "Material 1" pos:[0, 10] width:160 height:100
    -- Чекбокс
    checkbox mt_1_cb checked:true pos:[60, 10]
    -- Элемент для перетаскивания материала
    MaterialButton matBtn_1 "Select material" pos:[5, 30] width:150 height:20 filter:material
    -- Поле для ввода имени текстуры
    combobox cb_1  pos:[5, 50] items:#("Grass_128HV", "Grass_128HV2") width:150 height:3

    -----------------------ГРУППА 2-----------------------
    -- Группа материала
    groupBox grB_2 "Material 2" pos:[180, 10] width:160 height:100
    -- Чекбокс
    checkbox mt_2_cb checked:false pos:[240, 10]
    -- Элемент для перетаскивания материала
    MaterialButton matBtn_2 "Select material" pos:[185, 30] width:150 height:20 filter:material
    -- Поле для ввода имени текстуры
    combobox cb_2  pos:[185, 50] items:#("gb_sand_bottom", "gb_sand_bottom2") width:150 height:3




    ------------------------------------------------
    -- Кнопка применения материала
    button btnApply "Apply material" width:300
    -- by EgasVegas
    label lbl1 "by EgasVegas"  width:150 height:20 align:#center style_sunkenedge: true

    on textureMaterialApplicator open do (
        if (mt_2_cb.checked == false) then (
            matBtn_2.enabled = false
            cb_2.enabled = false
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
    -----------------------ОБРАБОТЧИКИ СПИСКОВ-----------------------
    on cb_1 entered txt do (
        cb_1.selected = txt
    )

    on cb_2 entered txt do (
        cb_2.selected = txt
    )

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

    on btnApply pressed do (
        local materialArray = #()
        local textureArray = #()

        local materialArray_1 = #() -- Создаем массив для хранения материала 1
        local textureArray_1 = #() -- Создаем массив для хранения списков текстур для материала 1

        local materialArray_2 = #() -- Создаем массив для хранения материала 1
        local textureArray_2 = #() -- Создаем массив для хранения списков текстур для материала 1
    
        -- Проверяем состояние чекбокса и добавляем соответствующие материалы и текстуры в массивы
        if mt_1_cb.checked and matBtn_1.material != undefined do (
            append materialArray_1 matBtn_1.material
            addTexturesToArray mt_1_cb cb_1 textureArray_1
        )

    
        if mt_2_cb.checked and matBtn_2.material != undefined do (
            append materialArray_2 matBtn_2.material
            addTexturesToArray mt_2_cb cb_2 textureArray_2
        )

        addArrayToArray materialArray materialArray_1
        addArrayToArray materialArray materialArray_2

        addArrayToArray textureArray textureArray_1
        addArrayToArray textureArray textureArray_2

        -- Проверяем, что было выбрано хотя бы одно сочетание материала и текстуры
        if materialArray.count > 0 and textureArray.count > 0 then (
            -- Вызываем функцию и передаем ей массивы материалов и текстур
            print (materialArray.count)
            print (textureArray.count)

            for i = 1 to materialArray.count do (
                applyMaterialToPolygonsWithTexture textureArray[i] materialArray[i]
            )

            messageBox "Done!"
        ) else (
            messageBox "Please specify both a material and a texture name."
        )
    )
    
)


-- Отображение интерфейса
createdialog textureMaterialApplicator 340 330