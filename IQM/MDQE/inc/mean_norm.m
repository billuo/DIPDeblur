function result = mean_norm(v, p)

result = mean(v .^ p) .^ (1.0 / p);

end
