package br.com.sigas.services;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.sigas.entities.Pessoas;
import br.com.sigas.repositories.PessoasRepository;
import jakarta.persistence.EntityNotFoundException;

@Service
public class PessoasService {

    @Autowired
    private PessoasRepository pessoaRepository;

    // Método para criar uma nova pessoa via procedimento armazenado
    public void inserirPessoa(Map<String, Object> dados) {
        String tipoPessoa = (String) dados.get("tipo_pessoa");
        String nome = (String) dados.get("nome");
        String email = (String) dados.get("email");
        String endereco = (String) dados.get("endereco");
        String tel1 = (String) dados.get("tel1");
        String tel2 = (String) dados.get("tel2");

        pessoaRepository.callInserirPessoa(tipoPessoa, nome, email, endereco, tel1, tel2);
    }

    // Método para atualizar uma pessoa via procedimento armazenado
    public void atualizarPessoaProcedure(Long id, Pessoas pessoaAtualizada) {
        pessoaRepository.callAtualizarPessoa(
                id,
                pessoaAtualizada.getNome_pessoa(),
                pessoaAtualizada.getEmail_pessoa(),
                pessoaAtualizada.getEndereco_pessoa(),
                pessoaAtualizada.getTel1_pessoa(),
                pessoaAtualizada.getTel2_pessoa());
    }

    // Método para deletar uma pessoa via procedimento armazenado
    public void deletarPessoaProcedure(Long id) {
        pessoaRepository.callDeletarPessoa(id);
    }

    // Métodos de consulta mantidos
    public Pessoas buscarPessoaPorId(Long id) {
        return pessoaRepository.buscarPessoaPorId(id)
                .orElseThrow(() -> new EntityNotFoundException("Pessoa não encontrada."));
    }

    public List<Pessoas> buscarPessoasPorNome(String nome) {
        return pessoaRepository.buscarPessoasPorNome(nome);
    }

    public List<Pessoas> buscarPessoasPorEmailContendo(String email) {
        return pessoaRepository.buscarPessoasPorEmailContendo(email);
    }

    public List<Pessoas> buscarPessoasAtivas() {
        return pessoaRepository.buscarPessoasAtivas();
    }
}
