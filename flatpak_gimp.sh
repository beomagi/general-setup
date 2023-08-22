flatpak install https://flathub.org/repo/appstream/org.gimp.GIMP.flatpakref

flatpak install org.gimp.GIMP.Plugin.Resynthesizer org.gimp.GIMP.Plugin.LiquidRescale org.gimp.GIMP.Plugin.Lensfun org.gimp.GIMP.Plugin.GMic org.gimp.GIMP.Plugin.Fourier org.gimp.GIMP.Plugin.FocusBlur org.gimp.GIMP.Plugin.BIMP



echo "flatpak run org.gimp.GIMP \$1" > /usr/local/bin/gimpf
