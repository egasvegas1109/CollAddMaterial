fn applyMaterialToPolygonsWithTexture textureName newMaterial = (
    for obj in objects do (
        convertToPoly obj
        weldAndSmoothGroup obj
        if classof obj.material == MultiMaterial then (
            -- Работаем с мультиматериалом
            local multiMat = obj.material
            for i = 1 to multiMat.numsubs do (
                local subMat = multiMat[i]
                if classof subMat.diffuseMap == BitmapTex and subMat.diffuseMap.fileName == textureName then (
                    multiMat[i] = newMaterial -- Заменяем суб-материал
                )
            )
        ) else (
            -- Работаем с одиночным материалом
            local mat = obj.material
            if classof mat.diffuseMap == BitmapTex and mat.diffuseMap.fileName == textureName then (
                obj.material = newMaterial -- Заменяем материал объекта
            )
        )
    )
    messageBox "Material has been applied to all matching textures."
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

-- Создание интерфейса
rollout textureMaterialApplicator "Texture material applicator"(
    -- Группа материала
    groupBox grB_1 "Material 1" pos:[0, 10] width:160 height:100
    -- Чекбокс
    checkbox mt_1_cb checked:true pos:[60, 10]
    -- Элемент для перетаскивания материала
    MaterialButton matBtn_1 "Select material" pos:[5, 30] width:150 height:20 filter:material
    -- Поле для ввода имени текстуры
    combobox cb_1  pos:[5, 50] items:#("Grass_128HV.png", "Grass_128HV2.png", "" ,"") width:150 height:3
    -- Кнопка применения материала
    button btnApply "Apply material" width:300
    -- by EgasVegas
    label lbl1 "by EgasVegas"  width:150 height:20 align:#center style_sunkenedge: true


    -- on textureMaterialApplicator open do (
    --     if mt_1_cb.checked = false then (
    --         matBtn_1.enabled = false
    --         cb_1.enabled = false
    --     )
    --  )

     on mt_1_cb changed theState do (
        matBtn_1.enabled = theState
        cb_1.enabled = theState
     )

    on cb_1 entered txt do (
        cb_1.selected = txt
    )

    on matBtn picked m do (
        if classof m == GTA_COLSurface then (
            matBtn.material = m
            matBtn.caption = m.name
        ) else (
            messageBox "Wrong format."
        )
    )

    on btnApply pressed do (
        if matBtn.material != undefined and txtTextureName.text != "" then (
            applyMaterialToPolygonsWithTexture txtTextureName.text matBtn.material
        ) else (
            messageBox "Please specify both a material and a texture name."
        )
    )
)

-- Отображение интерфейса
createdialog textureMaterialApplicator 500 330