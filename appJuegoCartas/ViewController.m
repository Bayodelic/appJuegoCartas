//  ViewController.m
//  appJuegoCartas
//
//  Created by braulio on 10/06/24.
//  Copyright © 2024 braulio. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;
@property(nonatomic) int flipCount;
@property (nonatomic, assign) BOOL isFrontal;
@property (nonatomic, strong) NSMutableArray *valoresCartas; // Arreglo para almacenar los valores de las cartas
@property (nonatomic, strong) NSMutableArray *cartasVolteadas; // Para guardar las cartas ya volteadas
@property (nonatomic, strong) NSString *valor1;
@property (nonatomic, strong) NSString *valor2;
@property (nonatomic, strong) NSMutableArray *cartasCoincidentes; // Para guardar las cartas coincidentes
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFrontal = NO;
    self.valoresCartas = [[NSMutableArray alloc] init];
    self.cartasVolteadas = [[NSMutableArray alloc] init];
    self.cartasCoincidentes = [[NSMutableArray alloc] init];
    [self generarValoresCartas];
}

- (IBAction)botonCarta:(UIButton *)sender {
    if (self.isFrontal) {
        [sender setBackgroundImage:[UIImage imageNamed:@"cartaTracera"] forState:UIControlStateNormal];
        [sender setTitle:@"" forState:UIControlStateNormal];
        self.isFrontal = NO;
    } else {
        NSUInteger index = [self.view.subviews indexOfObject:sender];
        if (index != NSNotFound && index < [self.valoresCartas count]) { // Verificar si el índice es válido
            NSString *valor = self.valoresCartas[index];
            [sender setBackgroundImage:[UIImage imageNamed:@"cartaFrontal"] forState:UIControlStateNormal];
            [sender setTitle:valor forState:UIControlStateNormal];
            self.isFrontal = YES;
            
            if (self.valor1 == nil) {
                self.valor1 = valor;
            } else {
                self.valor2 = valor;
                [self compararCartas];
            }
        } else {
            NSLog(@"Índice fuera de rango.");
        }
    }
    self.flipCount++;
    self.flipsLabel.text = [NSString stringWithFormat:@"%d", self.flipCount];
}



- (void)generarValoresCartas {
    NSArray *letras = @[@"A", @"2", @"3", @"4", @"5", @"6"];
    NSArray *palos = @[@"♥️", @"♦️", @"♠️", @"♣️"];
    NSMutableArray *valores = [[NSMutableArray alloc] init];
    NSMutableArray *valores2 = [[NSMutableArray alloc] init];
    NSMutableArray *valores3 = [[NSMutableArray alloc] init];
    
    for (NSString *letra in letras) {
        for (NSString *palo in palos) {
            NSString *valor = [NSString stringWithFormat:@"%@ %@", letra, palo];
            [valores addObject:valor];
            [valores2 addObject:valor];
        }
    }
    [valores3 addObject:[NSString stringWithFormat:@"%@ %@", @"x", @"x"]];

    // Barajar los valores de las cartas
    NSUInteger count = [valores count];
    for (NSUInteger i = 0; i < 6; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((uint32_t)remainingCount);
        [valores exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
        [valores2 exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
        
        [valores3 addObject:valores[i]];
        [valores3 addObject:valores2[i]];
    }
    
    NSUInteger count2 = [valores3 count];
    for (NSUInteger i = 1; i < count2; ++i) {
        NSInteger remainingCount = count2 - i;
        NSInteger exchangeIndex = i + arc4random_uniform((uint32_t)remainingCount);
        [valores3 exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    
    self.valoresCartas = valores3;
}




- (void)compararCartas {
    if ([self.valor1 isEqualToString:self.valor2]) {
        [self mostrarMensaje:@"¡Coincidencia!"];
        [self.cartasCoincidentes addObject:self.valor1];
        [self desactivarCartasCoincidentes];
    } else {
        [self mostrarMensaje:@"¡Intenta de nuevo!"];
        // Voltear las cartas de nuevo después de un breve retraso
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resetearCartas];
        });
    }
    self.valor1 = nil;
    self.valor2 = nil;
}

- (void)desactivarCartasCoincidentes {
    for (UIButton *button in self.view.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            NSString *titulo = [button titleForState:UIControlStateNormal];
            if ([self.cartasCoincidentes containsObject:titulo]) {
                button.userInteractionEnabled = NO;
                button.alpha = 0.5; // Cambiar opacidad para indicar que está desactivado
            }
        }
    }
}

- (void)resetearCartas {
    // Voltear las cartas a su estado original, pero mantener las cartas desactivadas
    self.valor1 = nil;
    self.valor2 = nil;
    self.isFrontal = NO;
    for (UIButton *button in self.view.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            NSString *titulo = [button titleForState:UIControlStateNormal];
            if (![self.cartasCoincidentes containsObject:titulo]) {
                [button setBackgroundImage:[UIImage imageNamed:@"cartaTracera"] forState:UIControlStateNormal];
                [button setTitle:@"" forState:UIControlStateNormal];
                button.userInteractionEnabled = YES; // Reactivar la interacción con las cartas no coincidentes
                button.alpha = 1.0; // Restaurar la opacidad a su valor original
            }
        }
    }
}

- (void)mostrarMensaje:(NSString *)mensaje {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Mensaje" message:mensaje preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
