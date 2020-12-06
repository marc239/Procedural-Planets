
rollout grin "Controles"(
	
	spinner radio "radio" type:#float
	spinner mon "Montañas" type:#float
	spinner con "Continentes" type:#float 
	spinner altcon "Altura de los continentes" type:#float 
	spinner altmon "Altura de las montañas" type:#float 
	spinner seg "Segmentos" type:#integer range:[0,10000,1]
	spinner alturaMar "Altura del mar" type:#float
	colorpicker colCap1 "Color de la capa 1" color:[23,196,0]
	checkBox capa2 "Activar capa 2" 
	colorpicker colCap2 "Color de la capa 2" enabled:false
	spinner altCap2 "Altura mínima de la capa 2" enabled:false
	checkBox capa3 "Activar capa 3" enabled: false
	colorpicker colCap3 "Color de la capa 3" enabled: false
	spinner altCap3 "Altura mínima de la capa 3" enabled:false
	checkBox capa4 "Activar capa 4" enabled: false
	colorpicker colCap4 "Activar capa 4" enabled: false
	spinner altCap4 "Altura mínima de la capa 4" enabled: false
	checkBox mar "Mar" checked:true
	colorpicker colMar "Color del mar" color:[0,0,255]
	checkBox nubesComp "Nubes"
	button crearPlaneta "Generar planeta"
	
	
	
	on grin open do (
		mon.value = 0.4
		con.value = 3
		altcon.value = 1
		altmon.value = 1
		radio.value =20
		seg.value = 200
		alturaMar.value = 0.3
	)
	
	on mar changed true do(
		if(mar.checked) then (
			colMar.enabled = true
			)
			else(
				colMar.enabled = false
				)
		
	)
	
	on capa2 changed true do(
		if(capa2.checked) then(
		colCap2.enabled = true
		altCap2.enabled = true
		capa3.enabled = true
		
		)
		else(
		colCap2.enabled = false
		altCap2.enabled = false
		capa3.enabled = false
		
		)
	)
	
	on capa3 changed true do(
		if(capa3.checked) then(
		colCap3.enabled = true
		altCap3.enabled = true
		capa4.enabled = true
		)
		else(
		colCap3.enabled = false
		altCap3.enabled = false
		capa4.enabled = false
		)
	)
	on capa4 changed true do(
		if(capa4.checked) then(
		colCap4.enabled = true
		altCap4.enabled = true
		)
		else(
		colCap4.enabled = false
		altCap4.enabled = false
		)
	)
	on crearPlaneta pressed do(
		aleatoriox = random 1 100
		aleatorioy = random 1 100
		aleatorioz = random 1 100
		auxmon = altmon.value/100; 

		esfera = geosphere radius:radio.value segments:seg.value

		
		fract_interval=mon.value
		 lacunarity=2
		octaves=5
		
		for esfera in Geometry do
			(

				convertToMesh esfera
			)
		fract2 = con.value
		
		altmar = radio.value + alturaMar.value
		--recorremos los puntos
		for i = 1 to esfera.numverts do
			(
			--print '1' + vert
			
			vert = getVert esfera i -- se guardan las coordenadas del punto
			
			ruido = fractalNoise [(vert.x*0.1*20/radio.value)+aleatoriox,( vert.y*0.1*20/radio.value)+aleatorioy, (vert.z*0.1*20/radio.value)+aleatorioz] fract_interval lacunarity octaves
			ruido2 = fractalNoise [(vert.x*0.1*20/radio.value)+aleatoriox, (vert.y*0.1*20/radio.value)+aleatorioy , (vert.z*0.1*20/radio.value)+aleatorioz] fract2 lacunarity octaves
			
				aux2 = pow (vert + vert * (pow (ruido2*2) 2)*0.05).x 2
				aux2 = aux2 + pow (vert + vert * (pow (ruido2*2) 2)*0.05).y 2
				aux2 = aux2 + pow (vert + vert * (pow (ruido2*2) 2)*0.05).z 2
				aux2 = sqrt aux2  --esto calcula la altura solo con el ruido de continentes
				
				if(mar.checked == false or aux2 > altmar-0.1) then
				vert = vert + vert*(pow (ruido*2) 2) *auxmon +vert*(pow (ruido2*2) 2) *0.05 
				else
				vert = vert + vert*(pow (ruido2*2) 2) * 0.05 
			
			setVert esfera i vert 
		)
		
		for i = 1 to getNumFaces esfera do (
			face = getFace esfera i
			ver1 = getVert esfera face[1]
			ver2 = getVert esfera face[2]
			ver3 = getVert esfera face[3]
			
			xtotal = (ver1.x+ver2.x+ver3.x) /3
			ytotal = (ver1.y+ver2.y+ver3.y) /3
			ztotal = (ver1.z+ver2.z+ver3.z) /3
			
			aux2 = pow xtotal 2
			aux2 = aux2 + pow ytotal 2
			aux2 = aux2 + pow ztotal 2
			aux2 = sqrt aux2 
			if(capa2.checked==true) then(
				if(aux2 > altCap2.value+altmar) then
					setFaceMatID esfera i 2
				else
					setFaceMatID esfera i 1
				
				if(capa3.checked == true) then (
					if(aux2 > altCap3.value+altmar) then
					setFaceMatID esfera i 3
					
					if(capa4.checked == true) then (
						if(aux2 > altCap4.value + altmar)	then (
							setFaceMatID esfera i 4
						)
					)
				)
			)
			else
			setFaceMatID esfera i 1
		)
		
		multi  = multimaterial numsubs:4
		multi.materialList[1] = PhysicalMaterial showInViewport:true Base_Color:colCap1.color
		multi.materialList[2] = PhysicalMaterial showInViewport:true Base_Color:colCap2.color
		multi.materialList[3] = PhysicalMaterial showInViewport:true Base_Color:colCap3.color
		multi.materialList[4] = PhysicalMaterial showInViewport:true Base_Color:colCap4.color
		esfera.material = multi
		
		if(mar.checked == true) then (
		mat2 = PhysicalMaterial showInViewport:true
		mat2.Base_Color = colMar.color
		esferaMar = geosphere radius:altmar segments:50 
		esferaMar.material = mat2
		)
		
		if(nubesComp.checked ==  true) then (
			altNubes = altmar + 1
			mat3 = PhysicalMaterial showinViewport:true
			esferaNubes = geosphere radius:altNubes segments:50 
			mat3.Base_color_map = noise type:0 thresholdHigh:0.618 size:2.3 
			
			ruido1 = noise type:1 thresholdHigh:0.38 
			transparencia = noise type:1 map1:ruido1 thresholdLow:0.505 size:6.3
			mat3.transparency_map = transparencia
			esferaNubes.material = mat3
		)
		)
		
	
)

theNewFloater = newRolloutFloater  "Generación de planetas" 300 600
addRollout grin theNewFloater