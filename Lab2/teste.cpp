#include <bits/stdc++.h>
using namespace std;

int main() {
    int x = 28306;
    int k = 10 * x / 2;
    for (int i = 0; i < 10; i++) {
        k = (k + 10 * x / k) / 2;
    }

    printf("Val: %d\n", k);
    return 0;
}
