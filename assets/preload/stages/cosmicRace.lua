function onCreate()
	-- background shit	
	makeLuaSprite('CosmicBG', 'stages/cosmic/CosmicBG', -225, -175);
	setScrollFactor('CosmicBG', 1, 1);
	scaleObject('CosmicBG', 1.2, 1.2);

	makeLuaSprite('CosmicBG2', 'stages/cosmic/CosmicBG2', 10, -175);
	setScrollFactor('CosmicBG2', 1, 1);
	scaleObject('CosmicBG2', 1.2, 1.2);

	makeLuaSprite('bluecometfilter','stages/cosmic/bluecometfilter',0,0)
	setLuaSpriteScrollFactor('bluecometfilter',160,90)
	addLuaSprite('bluecometfilter',true)

	setObjectCamera('bluecometfilter','camOther')

	setProperty('bluecometfilter.antialiasing',false)
	scaleObject('bluecometfilter',4,4)

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then

                  makeAnimatedLuaSprite('Smoke', 'stages/cosmic/CBF_Smoke', 1100, 340)addAnimationByPrefix('Smoke', 'dance', 'CBF Smoke Idle', 24, true)
                  objectPlayAnimation('Smoke', 'dance', false)
                  setScrollFactor('Smoke', 1, 1);
	setProperty('Smoke.visible', true)

                  makeAnimatedLuaSprite('Smoke2', 'stages/cosmic/CBF_Smoke', 380, 340)addAnimationByPrefix('Smoke2', 'dance', 'CBF Smoke Idle', 24, true)
                  objectPlayAnimation('Smoke2', 'dance', false)
                  setScrollFactor('Smoke2', 1, 1);
	setProperty('Smoke2.visible', true)
	setProperty('Smoke2.flipX', true)

	makeLuaSprite('dadShadow', 'DropShadow', 920, 590);
	scaleObject('dadShadow', 1.25, 1.2);
	setScrollFactor('dadShadow', 1, 1);
	setProperty('dadShadow.visible', true)
	setProperty('dadShadow.alpha', 0.4)

	makeLuaSprite('dadShadow2', 'DropShadow', 250, 590);
	scaleObject('dadShadow2', 1.25, 1.2);
	setScrollFactor('dadShadow2', 1, 1);
	setProperty('dadShadow2.visible', true)
	setProperty('dadShadow2.alpha', 0.4)

	end

	addLuaSprite('CosmicBG2', false);
	addLuaSprite('dadShadow2', false);
	addLuaSprite('Smoke2', false);
	addLuaSprite('CosmicBG', false);
	addLuaSprite('dadShadow', false);
	addLuaSprite('Smoke', false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end