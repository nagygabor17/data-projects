from functools import reduce
from collections import defaultdict
def count_word_occurrences(word_counts:dict, word:str):
    word_counts[word] = word_counts.get(word, 0) + 1
    return word_counts

PROHIBITED_WORDS = ["a", "az", "egy", "és", "hogy"]
text = input("Adjon meg egy szöveget: ").strip()
lowercase_words = map(str.lower, text.split())
filtered_words = filter(lambda x: x not in PROHIBITED_WORDS, lowercase_words)
#megtisztitott = list(filtered_words)
#eredmeny = dict(map(lambda szo: (szo, list(megtisztitott).count(szo)), megtisztitott))
#print(eredmeny)
#print(list(filtered_words))
#word_counts = reduce(count_word_occurrences, filtered_words, {})
#print(word_counts)

words2 = defaultdict(int)
for x in filtered_words:
    words2[x] +=1
print(words2)

most_common_words = sorted(words2.items(), key= lambda item: item[1], reverse=True)[:5]
print(most_common_words)

