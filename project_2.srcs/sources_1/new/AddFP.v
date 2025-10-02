module add(input [31:0]a, input [31:0] b, output reg [31:0] f);
    // Extraemos signos
    wire sig1 = a[31];
    wire sig2 = b[31];
    
    // Extraemos exponentes
    wire [7:0] exp1 = a[30:23];
    wire [7:0] exp2 = b[30:23];
    
    // Creamos las variables intermedias de mantisa y exponente
    reg [23:0] mantisa1;
    reg [23:0] mantisa2;
    reg [7:0] exp_i;
    
    // Igualar exponentes
    always @(*)
    begin
        // Si el exponete de a es mayor que b, 
        //emparejamos el exponete de b shifteando la mantisa de b
        if(exp1 > exp2)begin
            exp_i = exp1;
            mantisa1 = {1'b1, a[22:0]};
            mantisa2 = {1'b1, b[22:0]} >> (exp1 - exp2);
        end
        // Si el exponete de b es mayor que a, 
        //emparejamos el exponete de b shifteando la mantisa de a
        else begin
            exp_i = exp2;
            mantisa1 = {1'b1, a[22:0]} >> (exp2 - exp1);
            mantisa2 = {1'b1, b[22:0]};
        end
    end
    
    // mantisa final
    reg [24:0] mantisa_f;
    
    // exponente final
    reg [7:0] exp_f;
    
    
    wire sig_f = (mantisa1 > mantisa2) ? sig1 : sig2;
    always @(*)begin
       // Caso NaN
        if ((exp1 == 8'hFF && a[22:0] != 0) || (exp2 == 8'hFF && b[22:0] != 0)) begin
            f = 32'h7FC00000; // qNaN estandar
        end
        // Caso infinito
        else if (exp1 == 8'hFF && a[22:0] == 0) begin
            if (exp2 == 8'hFF && b[22:0] == 0 && sig1 != sig2)
                f = 32'h7FC00000; // inf - inf = NaN
            else
                f = a; // inf + x = inf
        end
        else if (exp2 == 8'hFF && b[22:0] == 0) begin
            f = b;
        end
        // Caso cero
        else if ((exp1 == 0 && a[22:0] == 0) && (exp2 == 0 && b[22:0] == 0)) begin
            f = {sig1 & sig2, 31'b0}; // podría ser +0 o -0, aquí pongo -0 si ambos eran -0
        end
        else if (exp1 == 0 && a[22:0] == 0) begin
            f = b;
        end
        else if (exp2 == 0 && b[22:0] == 0) begin
            f = a;
        end
        
        
        else begin
            // caso suma
            if(sig1 == sig2)
                mantisa_f = mantisa1 + mantisa2;
                
            // caso resta a + (-b) 
            else if(sig2 > sig1) begin
                mantisa_f = mantisa1 - mantisa2;
                end
            // caso resta b + (-a)
            else
                mantisa_f = mantisa2 - mantisa1;
    
            //si la suma o resta excede los 23 bits de mantisa, noramlizamos
            if(mantisa_f[24])begin
                exp_f = exp_i + 1; // suamos 1 al exponente
                f = {sig_f, exp_f, mantisa_f[23:1]}; // juntamos todo
            end
            // normalizamos hacia abajo si la mantisa es muy pequena
            else if(~mantisa_f[23])begin
                exp_f = exp_i - 1; // suamos 1 al exponente
                f = {sig_f, exp_f, mantisa_f[22:0], 1'b0}; // juntamos todo
            end
            //la suma o resta no excede los 23 bits de mantisa
            else begin
                exp_f = exp_i;
                f = {sig_f, exp_f, mantisa_f[22:0]}; // juntamos todo
                end    
         end
    end     
     
    
    
endmodule