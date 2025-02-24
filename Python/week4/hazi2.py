from functools import reduce
from collections import defaultdict

def count_word(word_counts:dict,word:str):
    word_counts[word] = word_counts.get(word,0)+1
    return word_counts

prohibited_words = ["a", "az", "egy", "és", ",", "hogy", "ez"]
text = input("Írj be valamit dikk: ").strip()
lowercase_words = map(str.lower,text.split())
filtered_words = filter(lambda x: x not in prohibited_words, lowercase_words)

#print(list(filtered_words))
word_counts = reduce(count_word, filtered_words, {})
print(word_counts.values())

words2 = defaultdict(int)
for x in filtered_words:
    words2[x] +=1
print(words2)

most_common_words = sorted(word_counts.items(), key=lambda item: item[1], reverse=True)[:5]
print(most_common_words)

