unit module Mimi::Team::Jaccard;

sub qgram (\a, \b, \q = (a.chars + b.chars) div 4 ) {
    my &ngrams = -> \t, \n {
        my \s = ~ (' ' x n - 1)
                ~ t
                ~ (' ' x n - 1);
        do for ^(t.chars + n) { s.substr: $_, n }
    }
    my \aₙ = &ngrams(a,q).BagHash;
    my \bₙ = &ngrams(b,q).BagHash;

    (aₙ ∩ bₙ) / (aₙ ∪ bₙ)
}

my &i  = method ($i) {$i ?? self.fc !! self}
my &m  = method ($i) {$i ?? self.samemark(' ') !! self}
my &ws = method ($i) {$i ?? self !! self.words.join }
my &p  = method ($i) {$i ?? self !! self.split(/<:P>/).join }

sub closest-match(:$query, :%team) is export {
    my @results = %team.keys
            .map({
                $^word,
                qgram
                $^word.&i(True),
                        $query
            })
            .sort( *.tail );

    return @results.sort( -*.[1] ).head(1).map({ .[0] => .[1] }).sort({ .value });
}
