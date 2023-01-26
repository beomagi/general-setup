
compileC2windows () { #DEFN use mingw to compile to windows
   x86_64-w64-mingw32-g++ -static -static-libgcc -static-libstdc++  $1
}


