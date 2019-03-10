
gitlog () { #DEFN simple output format for grabbing hashes to cherry-pick
   git log --pretty=format:"%H %aI %an: %s"
}


