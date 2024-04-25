fn applyMaterialToPolygonsWithTexture textureName newMaterial = (
    for obj in objects do (
        convertToPoly obj
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

-- Создание интерфейса
rollout textureMaterialApplicator "Texture Material Applicator"(
    -- Элемент для перетаскивания материала
    MaterialButton matBtn "Drag Material Here" across:2 width:160 height:40 filter:material
    -- Поле для ввода имени текстуры
    editText txtTextureName "Texture Name" width:160


    -- Кнопка применения материала
    button btnApply "Apply Material" width:160

    on textureMaterialApplicator open do (
        txtTextureName.text = "Grass_128HV2.png"
    )

    on matBtn picked m do (
        if classof m == Material then (
            matBtn.material = m
            matBtn.caption = m.name
        ) else (
            messageBox "Please drag a material onto the button."
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
createdialog textureMaterialApplicator 500 330 style:#(#style_toolwindow, #style_sysmenu)
